class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    case current_user.role
    when 'learner'
      setup_learner_dashboard
    when 'instructor'
      setup_instructor_dashboard
    when 'administrator'
      setup_admin_dashboard
    end
  end

  private

  def setup_learner_dashboard
    @available_journals = Journal.published
                                 .where(visibility: ['public_access', 'unlisted'])
                                 .includes(:user, :theme, :questions)
                                 .limit(5)
    @recent_submissions = current_user.journal_submissions
                                     .includes(journal: [:user, :theme])
                                     .order(updated_at: :desc)
                                     .limit(5)
    @new_journals_this_week = Journal.where(created_at: 1.week.ago..Time.current).count
  end

  def setup_instructor_dashboard
    @my_journals = current_user.journals
                              .includes(:theme, :questions, :journal_submissions)
                              .order(updated_at: :desc)
                              .limit(5)
    @recent_submissions = JournalSubmission.joins(:journal)
                                          .where(journals: { user: current_user })
                                          .includes(:user, journal: [:theme])
                                          .order(updated_at: :desc)
                                          .limit(10)
  end

  def setup_admin_dashboard
    @total_users = User.count
    @total_journals = Journal.count
    @total_submissions = JournalSubmission.count
    @recent_activity = JournalSubmission.includes(:user, journal: [:user, :theme])
                                       .order(updated_at: :desc)
                                       .limit(10)
  end
end
