class AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_analytics_access

  def index
    @overview_stats = calculate_overview_stats
    @recent_activity = get_recent_activity
    @completion_trends = calculate_completion_trends
    @user_engagement = calculate_user_engagement
  rescue => e
    Rails.logger.error "Error in analytics index: #{e.message}"
    @overview_stats = { total_users: 0, total_journals: 0, total_submissions: 0, total_responses: 0, average_completion_rate: 0, active_users_this_week: 0 }
    @recent_activity = []
    @completion_trends = []
    @user_engagement = { daily_active_users: 0, weekly_active_users: 0, monthly_active_users: 0 }
  end

  def user_analytics
    @user_stats = calculate_user_stats
    @users_by_role = User.group(:role).count.presence || { 'learner' => 0 }
    @user_activity = calculate_user_activity_metrics
    @top_active_users = get_top_active_users
  rescue => e
    Rails.logger.error "Error in user analytics: #{e.message}"
    @user_stats = { total_users: 0, learners: 0, instructors: 0, administrators: 0, users_with_submissions: 0, average_submissions_per_user: 0 }
    @users_by_role = {}
    @user_activity = []
    @top_active_users = []
  end

  def journal_analytics
    @journal_stats = calculate_journal_stats
    @journals_by_status = Journal.group(:status).count.presence || { 'draft' => 0 }
    @completion_rates = calculate_journal_completion_rates
    @response_trends = calculate_response_trends
    @popular_question_types = calculate_question_type_usage
  rescue => e
    Rails.logger.error "Error in journal analytics: #{e.message}"
    @journal_stats = { total_journals: 0, published_journals: 0, draft_journals: 0, journals_with_submissions: 0, average_questions_per_journal: 0, average_submissions_per_journal: 0 }
    @journals_by_status = {}
    @completion_rates = []
    @response_trends = []
    @popular_question_types = {}
  end

  def export
    @overview_stats = calculate_overview_stats
    @user_stats = calculate_user_stats
    @journal_stats = calculate_journal_stats
    
    respond_to do |format|
      format.html # renders export.html.erb
      format.csv { send_analytics_csv }
      format.pdf { send_analytics_pdf }
    end
  end

  def dashboard_data
    render json: {
      completion_trends: calculate_completion_trends,
      user_engagement: calculate_user_engagement,
      daily_activity: calculate_daily_activity
    }
  end

  private

  def authorize_analytics_access
    unless current_user.instructor? || current_user.administrator?
      redirect_to root_path, alert: 'Access denied. Analytics are only available to instructors and administrators.'
    end
  end

  def calculate_overview_stats
    {
      total_users: User.count || 0,
      total_journals: Journal.count || 0,
      total_submissions: JournalSubmission.count || 0,
      total_responses: Response.count || 0,
      average_completion_rate: calculate_average_completion_rate || 0,
      active_users_this_week: (User.joins(:journal_submissions)
                                  .where(journal_submissions: { updated_at: 1.week.ago..Time.current })
                                  .distinct.count rescue 0)
    }
  end

  def get_recent_activity
    JournalSubmission.includes(:user, :journal)
                    .order(updated_at: :desc)
                    .limit(10)
  rescue => e
    Rails.logger.error "Error fetching recent activity: #{e.message}"
    []
  end

  def calculate_completion_trends
    last_30_days = 30.days.ago.to_date..Date.current
    
    last_30_days.map do |date|
      {
        date: date,
        submissions: JournalSubmission.where(completed_at: date.beginning_of_day..date.end_of_day).count,
        new_users: User.where(created_at: date.beginning_of_day..date.end_of_day).count
      }
    end
  end

  def calculate_user_engagement
    {
      daily_active_users: (User.joins(:responses)
                             .where(responses: { updated_at: 1.day.ago..Time.current })
                             .distinct.count rescue 0),
      weekly_active_users: (User.joins(:responses)
                              .where(responses: { updated_at: 1.week.ago..Time.current })
                              .distinct.count rescue 0),
      monthly_active_users: (User.joins(:responses)
                               .where(responses: { updated_at: 1.month.ago..Time.current })
                               .distinct.count rescue 0)
    }
  end

  def calculate_user_stats
    user_count = User.count
    {
      total_users: user_count || 0,
      learners: User.where(role: 'learner').count || 0,
      instructors: User.where(role: 'instructor').count || 0,
      administrators: User.where(role: 'administrator').count || 0,
      users_with_submissions: (User.joins(:journal_submissions).distinct.count rescue 0),
      average_submissions_per_user: user_count > 0 ? (JournalSubmission.count.to_f / user_count) : 0
    }
  end

  def calculate_user_activity_metrics
    User.joins(:journal_submissions)
        .group('users.id', 'users.first_name', 'users.last_name', 'users.email')
        .select("users.*, COUNT(journal_submissions.id) as submission_count,
                 AVG(CASE WHEN journal_submissions.status = 'submitted' THEN 100.0 ELSE 0.0 END) as avg_completion_rate")
        .order('submission_count DESC')
        .limit(20)
  rescue => e
    Rails.logger.error "Error calculating user activity metrics: #{e.message}"
    []
  end

  def get_top_active_users
    User.joins(:responses)
        .where(responses: { updated_at: 1.month.ago..Time.current })
        .group('users.id', 'users.first_name', 'users.last_name')
        .select('users.*, COUNT(responses.id) as response_count')
        .order('response_count DESC')
        .limit(10)
  rescue => e
    Rails.logger.error "Error getting top active users: #{e.message}"
    []
  end

  def calculate_journal_stats
    journal_count = Journal.count
    {
      total_journals: journal_count || 0,
      published_journals: Journal.where(published: true).count || 0,
      draft_journals: Journal.where(published: false).count || 0,
      journals_with_submissions: (Journal.joins(:journal_submissions).distinct.count rescue 0),
      average_questions_per_journal: journal_count > 0 ? (Question.count.to_f / journal_count) : 0,
      average_submissions_per_journal: journal_count > 0 ? (JournalSubmission.count.to_f / journal_count) : 0
    }
  end

  def calculate_journal_completion_rates
    Journal.joins(:journal_submissions)
           .group('journals.id', 'journals.title')
           .select("journals.*, 
                    COUNT(journal_submissions.id) as total_submissions,
                    COUNT(CASE WHEN journal_submissions.status = 'submitted' THEN 1 END) as completed_submissions,
                    ROUND(COUNT(CASE WHEN journal_submissions.status = 'submitted' THEN 1 END) * 100.0 / COUNT(journal_submissions.id), 2) as completion_rate")
           .order('completion_rate DESC')
  rescue => e
    Rails.logger.error "Error calculating journal completion rates: #{e.message}"
    []
  end

  def calculate_response_trends
    last_7_days = 7.days.ago.to_date..Date.current
    
    last_7_days.map do |date|
      {
        date: date,
        responses: (Response.where(updated_at: date.beginning_of_day..date.end_of_day).count rescue 0)
      }
    end
  rescue => e
    Rails.logger.error "Error calculating response trends: #{e.message}"
    []
  end

  def calculate_question_type_usage
    Question.group(:question_type).count
  rescue => e
    Rails.logger.error "Error calculating question type usage: #{e.message}"
    {}
  end

  def calculate_average_completion_rate
    submissions = JournalSubmission.all
    return 0 if submissions.empty?
    
    total_rate = submissions.sum(&:completion_percentage)
    (total_rate.to_f / submissions.count).round(2)
  rescue => e
    Rails.logger.error "Error calculating average completion rate: #{e.message}"
    0
  end

  def calculate_daily_activity
    last_7_days = 7.days.ago.to_date..Date.current
    
    last_7_days.map do |date|
      {
        date: date,
        logins: User.where(updated_at: date.beginning_of_day..date.end_of_day).count,
        responses: Response.where(created_at: date.beginning_of_day..date.end_of_day).count,
        submissions: JournalSubmission.where(created_at: date.beginning_of_day..date.end_of_day).count
      }
    end
  end

  def send_analytics_csv
    csv_data = generate_analytics_csv
    send_data csv_data, filename: "analytics_report_#{Date.current}.csv", type: 'text/csv'
  end

  def send_analytics_pdf
    pdf_data = generate_analytics_pdf
    send_data pdf_data, filename: "analytics_report_#{Date.current}.pdf", type: 'application/pdf'
  end

  def generate_analytics_csv
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << ['Metric', 'Value']
      @overview_stats.each { |key, value| csv << [key.to_s.humanize, value] }
    end
  end

  def generate_analytics_pdf
    html_content = render_to_string('analytics/export', layout: false)
    
    # Simple PDF placeholder - in production you'd use a proper PDF gem
    pdf_content = <<~PDF
      %PDF-1.4
      1 0 obj
      <<
      /Type /Catalog
      /Pages 2 0 R
      >>
      endobj
      
      2 0 obj
      <<
      /Type /Pages
      /Kids [3 0 R]
      /Count 1
      >>
      endobj
      
      3 0 obj
      <<
      /Type /Page
      /Parent 2 0 R
      /MediaBox [0 0 612 792]
      /Contents 4 0 R
      >>
      endobj
      
      4 0 obj
      <<
      /Length #{html_content.length + 100}
      >>
      stream
      BT
      /F1 12 Tf
      72 720 Td
      (Pondero Analytics Report - #{Date.current}) Tj
      0 -24 Td
      (Total Users: #{@overview_stats[:total_users]}) Tj
      0 -24 Td
      (Total Journals: #{@overview_stats[:total_journals]}) Tj
      0 -24 Td
      (Total Submissions: #{@overview_stats[:total_submissions]}) Tj
      ET
      endstream
      endobj
      
      xref
      0 5
      0000000000 65535 f 
      0000000009 00000 n 
      0000000074 00000 n 
      0000000120 00000 n 
      0000000179 00000 n 
      trailer
      <<
      /Size 5
      /Root 1 0 R
      >>
      startxref
      #{400 + html_content.length}
      %%EOF
    PDF
    
    pdf_content
  end
end
