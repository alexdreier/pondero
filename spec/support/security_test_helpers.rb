# frozen_string_literal: true

# Enterprise Security Testing Helpers
# Microsoft-level security testing utilities

module SecurityTestHelpers
  # Authentication Security Tests
  def expect_authentication_required(path)
    visit path
    expect(page).to have_current_path(new_user_session_path)
  end

  def expect_authorization_required(path, user_role: :learner)
    user = create(:user, role: user_role)
    sign_in user
    visit path
    expect(page).to have_http_status(:forbidden).or have_content('Access denied')
  end

  # Input Validation Security
  def test_sql_injection_protection(field, form_selector = 'form')
    malicious_inputs = [
      "'; DROP TABLE users; --",
      "1' OR '1'='1",
      "admin'--",
      "1' UNION SELECT * FROM users--"
    ]

    malicious_inputs.each do |input|
      within(form_selector) do
        fill_in field, with: input
        click_button 'Submit'
      end
      
      # Should not see database errors or unauthorized data
      expect(page).not_to have_content('mysql', 'postgresql', 'sqlite')
      expect(page).not_to have_content('SQL', 'syntax error')
    end
  end

  def test_xss_protection(field, form_selector = 'form')
    xss_payloads = [
      '<script>alert("XSS")</script>',
      '"><script>alert("XSS")</script>',
      'javascript:alert("XSS")',
      '<img src=x onerror=alert("XSS")>',
      '{{constructor.constructor("alert(1)")()}}'
    ]

    xss_payloads.each do |payload|
      within(form_selector) do
        fill_in field, with: payload
        click_button 'Submit'
      end
      
      # Should not execute JavaScript
      expect(page.driver.browser.switch_to.alert).to raise_error(Selenium::WebDriver::Error::NoSuchAlertError)
      expect(page.html).not_to include('<script>')
    rescue Selenium::WebDriver::Error::NoSuchAlertError
      # This is expected - no alert should be present
    end
  end

  def test_csrf_protection(form_selector = 'form')
    # Attempt to submit form without CSRF token
    page.execute_script("document.querySelector('#{form_selector} input[name=\"authenticity_token\"]').remove()")
    
    within(form_selector) do
      click_button 'Submit'
    end
    
    expect(page).to have_content('Invalid authenticity token').or have_http_status(:forbidden)
  end

  # Session Security
  def test_session_timeout
    sign_in create(:user)
    
    # Simulate session timeout
    Capybara.current_session.driver.browser.manage.delete_all_cookies
    
    visit dashboard_path
    expect(page).to have_current_path(new_user_session_path)
  end

  def test_session_fixation_protection
    # Get session ID before login
    visit root_path
    session_before = get_session_id
    
    # Login
    sign_in create(:user)
    session_after = get_session_id
    
    # Session ID should change after authentication
    expect(session_before).not_to eq(session_after)
  end

  # File Upload Security
  def test_file_upload_security(file_field)
    malicious_files = [
      { name: 'script.php', content: '<?php system($_GET["cmd"]); ?>' },
      { name: 'shell.jsp', content: '<%@page import="java.io.*"%>' },
      { name: 'test.exe', content: 'MZ' + "\x00" * 100 },
      { name: '../../../etc/passwd', content: 'root:x:0:0:root:/root:/bin/bash' }
    ]

    malicious_files.each do |file|
      temp_file = create_temp_file(file[:name], file[:content])
      
      attach_file file_field, temp_file.path
      click_button 'Submit'
      
      # Should reject malicious files
      expect(page).to have_content('Invalid file type').or have_content('Upload failed')
      
      temp_file.unlink
    end
  end

  # API Security Testing
  def test_api_rate_limiting(endpoint, method: :get, limit: 100)
    (limit + 10).times do |i|
      case method
      when :get
        get endpoint
      when :post
        post endpoint, params: { test: i }
      end
      
      if i > limit
        expect(response).to have_http_status(:too_many_requests)
        break
      end
    end
  end

  def test_api_authentication_required(endpoint, method: :get)
    case method
    when :get
      get endpoint
    when :post
      post endpoint
    when :put
      put endpoint
    when :delete
      delete endpoint
    end
    
    expect(response).to have_http_status(:unauthorized)
  end

  # Header Security
  def expect_security_headers
    security_headers = {
      'X-Frame-Options' => 'DENY',
      'X-Content-Type-Options' => 'nosniff',
      'X-XSS-Protection' => '1; mode=block',
      'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy' => /default-src 'self'/
    }

    security_headers.each do |header, expected_value|
      actual_value = response.headers[header]
      expect(actual_value).to be_present
      
      if expected_value.is_a?(Regexp)
        expect(actual_value).to match(expected_value)
      else
        expect(actual_value).to eq(expected_value)
      end
    end
  end

  # Sensitive Data Protection
  def expect_no_sensitive_data_exposure
    sensitive_patterns = [
      /password\s*[:=]\s*['"]\w+['"]/i,
      /api[_-]?key\s*[:=]\s*['"]\w+['"]/i,
      /secret\s*[:=]\s*['"]\w+['"]/i,
      /token\s*[:=]\s*['"]\w+['"]/i,
      /database_url/i,
      /rails_master_key/i
    ]

    sensitive_patterns.each do |pattern|
      expect(page.html).not_to match(pattern)
      expect(response.body).not_to match(pattern)
    end
  end

  # Audit Logging
  def expect_audit_log_entry(action:, user:, resource: nil)
    expect(AuditLog.where(
      action: action,
      user: user,
      resource: resource
    )).to exist
  end

  private

  def get_session_id
    page.driver.browser.manage.cookie_named('_session_id')&.fetch(:value)
  end

  def create_temp_file(name, content)
    temp_file = Tempfile.new([name.split('.').first, ".#{name.split('.').last}"])
    temp_file.write(content)
    temp_file.rewind
    temp_file
  end
end