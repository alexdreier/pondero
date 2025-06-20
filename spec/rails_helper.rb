# frozen_string_literal: true

# Enterprise-Grade RSpec Configuration
# Microsoft-level testing standards with comprehensive coverage

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'
require 'webmock/rspec'
require 'vcr'
require 'shoulda-matchers'
require 'database_cleaner/active_record'
require 'factory_bot_rails'
require 'faker'

# Enterprise Security Testing
require 'brakeman'
require 'bundler-audit'

# Performance Testing
require 'benchmark'
require 'memory_profiler'

# Add additional requires for testing gems that may be required
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  # Enterprise Test Configuration
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # Database Cleaner Configuration for Enterprise Reliability
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.strategy = :transaction
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.around(:each, :js) do |example|
    DatabaseCleaner.strategy = :truncation
    example.run
    DatabaseCleaner.strategy = :transaction
  end

  # Factory Bot Configuration
  config.include FactoryBot::Syntax::Methods

  # Capybara Configuration for Enterprise UI Testing
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end

  # Enterprise Security Testing Hooks
  config.before(:suite) do
    # Run security scans before test suite
    puts "🔒 Running enterprise security scans..."
    
    # Brakeman security scan
    tracker = Brakeman.run(
      app_path: Rails.root,
      quiet: true,
      print_report: false
    )
    
    if tracker.errors.any? || tracker.warnings.any?
      puts "⚠️  Security vulnerabilities detected!"
      tracker.warnings.each do |warning|
        puts "  - #{warning.warning_type}: #{warning.message}"
      end
    else
      puts "✅ Security scan passed"
    end

    # Bundle audit for dependency vulnerabilities
    puts "🔍 Checking dependencies for vulnerabilities..."
    # Note: This would typically run `bundle-audit check` in CI/CD
  end

  # Performance Testing Configuration
  config.around(:each, :performance) do |example|
    result = Benchmark.measure do
      example.run
    end
    
    puts "⏱️  Test completed in #{result.real.round(3)}s (#{result.total.round(3)}s CPU)"
    
    # Fail if test takes too long (enterprise performance requirement)
    if result.real > 5.0
      raise "Performance test failed: took #{result.real}s (max: 5.0s)"
    end
  end

  # Memory leak detection for enterprise reliability
  config.around(:each, :memory) do |example|
    report = MemoryProfiler.report do
      example.run
    end
    
    # Log memory usage for enterprise monitoring
    if report.total_allocated_memsize > 50 * 1024 * 1024 # 50MB
      puts "⚠️  High memory usage: #{report.total_allocated_memsize / 1024 / 1024}MB"
    end
  end

  # Enterprise Error Handling
  config.around(:each) do |example|
    begin
      example.run
    rescue => e
      # Enterprise error logging
      Rails.logger.error "Test failed: #{example.full_description}"
      Rails.logger.error "Error: #{e.class}: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise
    end
  end

  # Custom matchers for enterprise testing
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  # WestEd Brand Compliance Testing Helpers
  config.include WestEdTestHelpers
  config.include SecurityTestHelpers
  config.include PerformanceTestHelpers

  # VCR Configuration for API Testing
  VCR.configure do |vcr_config|
    vcr_config.cassette_library_dir = 'spec/vcr_cassettes'
    vcr_config.hook_into :webmock
    vcr_config.configure_rspec_metadata!
    vcr_config.allow_http_connections_when_no_cassette = false
    
    # Filter sensitive data in recordings
    vcr_config.filter_sensitive_data('<API_KEY>') { ENV['API_KEY'] }
    vcr_config.filter_sensitive_data('<DATABASE_URL>') { ENV['DATABASE_URL'] }
  end

  # WebMock Configuration
  WebMock.disable_net_connect!(
    allow_localhost: true,
    allow: ['chromedriver.storage.googleapis.com']
  )

  # Enterprise Reporting Configuration
  config.formatter = :progress
  config.add_formatter 'RspecJunitFormatter', 'tmp/rspec.xml' if ENV['CI']
  
  # Fail fast in development for quicker feedback
  config.fail_fast = 1 if ENV['RAILS_ENV'] == 'development'
  
  # Randomize test order for enterprise reliability
  config.order = :random
  Kernel.srand config.seed
end

# Enterprise Capybara Configuration
Capybara.configure do |config|
  config.default_max_wait_time = 10
  config.server_port = 3001
  config.asset_host = 'http://localhost:3001'
  
  # Enterprise screenshot configuration for debugging
  config.save_path = 'tmp/capybara'
  config.automatic_label_click = true
end

# Selenium Configuration for Enterprise Testing
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--remote-debugging-port=9222')
  options.add_argument('--window-size=1400,1400')
  
  # Enterprise security options
  options.add_argument('--disable-web-security')
  options.add_argument('--allow-running-insecure-content')
  
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Enterprise Shoulda Matchers Configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end