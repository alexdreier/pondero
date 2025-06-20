# frozen_string_literal: true

# Enterprise WestEd Testing Helpers
# Microsoft-level testing utilities for brand compliance and functionality

module WestEdTestHelpers
  # Brand Compliance Testing
  def expect_wested_branding(page_content)
    expect(page_content).to include('WestEd')
    expect(page_content).to include('Pondero')
  end

  def expect_wested_colors(element)
    # Verify WestEd color compliance
    computed_style = element.native.css_value('color')
    wested_colors = [
      'rgb(0, 70, 127)',    # Primary Blue
      'rgb(84, 185, 72)',   # Primary Green  
      'rgb(60, 54, 117)',   # Purple 1
      'rgb(92, 80, 195)'    # Purple 2
    ]
    
    expect(wested_colors).to include(computed_style)
  end

  def expect_accessibility_compliance(page)
    # Basic accessibility checks
    expect(page).to have_css('html[lang]')
    expect(page).to have_css('title')
    
    # Check for alt text on images
    page.all('img').each do |img|
      expect(img[:alt]).not_to be_empty
    end
    
    # Check for proper heading hierarchy
    headings = page.all('h1, h2, h3, h4, h5, h6').map(&:tag_name)
    expect(headings.first).to eq('h1') if headings.any?
  end

  def expect_enterprise_performance(page, max_load_time: 3.0)
    start_time = Time.current
    yield if block_given?
    load_time = Time.current - start_time
    
    expect(load_time).to be < max_load_time
  end

  # User Role Testing Helpers
  def sign_in_as_admin
    admin = create(:user, :admin)
    sign_in admin
    admin
  end

  def sign_in_as_instructor
    instructor = create(:user, :instructor)
    sign_in instructor
    instructor
  end

  def sign_in_as_learner
    learner = create(:user, :learner)
    sign_in learner
    learner
  end

  # Navigation Testing
  def expect_admin_navigation
    expect(page).to have_link('Users')
    expect(page).to have_link('Analytics')
    expect(page).to have_link('Themes')
  end

  def expect_instructor_navigation
    expect(page).to have_link('Templates')
    expect(page).to have_link('Analytics')
    expect(page).not_to have_link('Users')
  end

  def expect_learner_navigation
    expect(page).to have_link('Dashboard')
    expect(page).to have_link('Journals')
    expect(page).not_to have_link('Templates')
    expect(page).not_to have_link('Analytics')
  end

  # Component Testing Helpers
  def expect_stats_card(title:, value:, icon: nil)
    within('.wested-stats-card') do
      expect(page).to have_content(title)
      expect(page).to have_content(value.to_s)
      expect(page).to have_css('.stats-icon') if icon
    end
  end

  def expect_wested_logo(variant: :desktop)
    expect(page).to have_css('.wested-logo')
    
    case variant
    when :desktop
      expect(page).to have_css('.wested-logo[width="80"]')
    when :mobile
      expect(page).to have_css('.wested-logo[width="60"]')
    end
  end

  # Data Factory Helpers
  def create_journal_with_questions(question_count: 3)
    journal = create(:journal)
    question_count.times do |i|
      create(:question, journal: journal, position: i + 1)
    end
    journal
  end

  def create_complete_submission(user, journal)
    submission = create(:journal_submission, user: user, journal: journal)
    journal.questions.each do |question|
      create(:response, 
             journal_submission: submission, 
             question: question,
             content: "Sample response to #{question.title}")
    end
    submission.update!(status: 'submitted', completed_at: Time.current)
    submission
  end

  # Analytics Testing Helpers
  def expect_analytics_charts
    expect(page).to have_css('#engagementChart')
    expect(page).to have_css('#trendsChart')
    expect(page).to have_css('#heatmapChart')
    expect(page).to have_css('#radarChart')
  end

  def expect_analytics_data(data_type:, min_count: 1)
    case data_type
    when :users
      expect(page).to have_css('.stats-card', text: 'Total Users')
    when :journals
      expect(page).to have_css('.stats-card', text: 'Total Journals')
    when :submissions
      expect(page).to have_css('.stats-card', text: 'Total Submissions')
    end
  end

  # Security Testing Helpers
  def expect_secure_headers
    expect(response.headers['X-Frame-Options']).to be_present
    expect(response.headers['X-Content-Type-Options']).to eq('nosniff')
    expect(response.headers['X-XSS-Protection']).to be_present
  end

  def expect_csrf_protection
    expect(page).to have_css('meta[name="csrf-token"]')
  end

  # Performance Testing Helpers
  def measure_page_load(&block)
    start_time = Time.current
    block.call
    Time.current - start_time
  end

  def expect_efficient_queries(max_queries: 10)
    query_count = 0
    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do
      query_count += 1
    end
    
    yield
    
    ActiveSupport::Notifications.unsubscribe(subscription)
    expect(query_count).to be <= max_queries
  end

  # Error Handling Testing
  def simulate_server_error
    allow_any_instance_of(ApplicationController)
      .to receive(:render)
      .and_raise(StandardError, 'Simulated server error')
  end

  def expect_graceful_error_handling
    expect(page).to have_content('Something went wrong')
    expect(page).not_to have_content('StandardError')
    expect(page).not_to have_content('backtrace')
  end
end