class LtiController < ApplicationController
  skip_before_action :authenticate_user!, only: [:launch, :config, :configure]
  skip_before_action :verify_authenticity_token, only: [:launch]

  before_action :validate_lti_request, only: [:launch]

  def launch
    begin
      # Extract user information from LTI request
      user_data = extract_user_data
      
      # Find or create user based on LTI data
      @user = find_or_create_lti_user(user_data)
      
      # Sign in the user
      sign_in @user
      
      # Check if this is a specific journal launch
      if params[:custom_journal_id].present?
        journal = Journal.find_by(id: params[:custom_journal_id])
        if journal && journal.accessible_to?(@user)
          redirect_to journal
        else
          redirect_to root_path, alert: 'Journal not found or access denied.'
        end
      else
        # Redirect to dashboard
        redirect_to root_path, notice: 'Successfully signed in via Canvas LTI.'
      end
    rescue => e
      Rails.logger.error "LTI Launch Error: #{e.message}\nParams: #{params.inspect}"
      redirect_to new_user_session_path, alert: 'LTI authentication failed. Please try again.'
    end
  end

  def configure
    # Show LTI configuration instructions
  end

  def config
    # Generate LTI tool configuration XML
    respond_to do |format|
      format.xml { render xml: lti_config_xml }
    end
  end

  private

  def validate_lti_request
    consumer_key = Rails.application.credentials.dig(:lti, :consumer_key) || 'pondero_lti_key'
    shared_secret = Rails.application.credentials.dig(:lti, :shared_secret) || 'pondero_shared_secret_12345'
    
    @provider = IMS::LTI::ToolProvider.new(
      consumer_key,
      shared_secret,
      params
    )

    unless @provider.valid_request?(request)
      Rails.logger.error "Invalid LTI request: #{@provider.outcome_service}"
      render plain: 'Invalid LTI request', status: :unauthorized
      return false
    end
  end

  def extract_user_data
    {
      email: params[:lis_person_contact_email_primary] || "#{params[:user_id]}@lti.example.com",
      first_name: params[:lis_person_name_given] || params[:custom_canvas_user_name] || 'Unknown',
      last_name: params[:lis_person_name_family] || 'User',
      lti_user_id: params[:user_id],
      role: determine_role_from_lti
    }
  end

  def determine_role_from_lti
    roles = params[:roles]&.downcase || ''
    
    if roles.include?('instructor') || roles.include?('teacher') || roles.include?('contentdeveloper')
      'instructor'
    elsif roles.include?('administrator')
      'administrator'
    else
      'learner'
    end
  end

  def find_or_create_lti_user(user_data)
    # First try to find by LTI user ID
    user = User.find_by(lti_user_id: user_data[:lti_user_id])
    
    # If not found, try by email
    user ||= User.find_by(email: user_data[:email])
    
    # Create new user if not found
    user ||= User.create!(
      email: user_data[:email],
      first_name: user_data[:first_name],
      last_name: user_data[:last_name],
      role: user_data[:role],
      lti_user_id: user_data[:lti_user_id],
      password: SecureRandom.hex(20) # Random password since they'll use LTI
    )
    
    # Update LTI user ID if it was missing
    if user.lti_user_id.blank?
      user.update!(lti_user_id: user_data[:lti_user_id])
    end
    
    user
  end

  def lti_config_xml
    host = request.host_with_port
    protocol = request.ssl? ? 'https' : 'http'
    
    <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <cartridge_basiclti_link xmlns="http://www.imsglobal.org/xsd/imslticc_v1p0"
          xmlns:blti="http://www.imsglobal.org/xsd/imsbasiclti_v1p0"
          xmlns:lticm="http://www.imsglobal.org/xsd/imslticm_v1p0"
          xmlns:lticp="http://www.imsglobal.org/xsd/imslticp_v1p0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://www.imsglobal.org/xsd/imslticc_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticc_v1p0.xsd
          http://www.imsglobal.org/xsd/imsbasiclti_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imsbasiclti_v1p0.xsd
          http://www.imsglobal.org/xsd/imslticm_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticm_v1p0.xsd
          http://www.imsglobal.org/xsd/imslticp_v1p0 http://www.imsglobal.org/xsd/lti/ltiv1p0/imslticp_v1p0.xsd">
        
        <blti:title>Pondero - Reflective Journaling</blti:title>
        <blti:description>A comprehensive journaling platform for structured reflection and learning assessment.</blti:description>
        <blti:launch_url>#{protocol}://#{host}/lti/launch</blti:launch_url>
        <blti:secure_launch_url>#{protocol}://#{host}/lti/launch</blti:secure_launch_url>
        <blti:vendor>
          <lticp:code>pondero</lticp:code>
          <lticp:name>Pondero</lticp:name>
          <lticp:description>Reflective journaling platform</lticp:description>
          <lticp:url>#{protocol}://#{host}</lticp:url>
          <lticp:contact>
            <lticp:email>support@pondero.app</lticp:email>
          </lticp:contact>
        </blti:vendor>
        
        <blti:extensions platform="canvas.instructure.com">
          <lticm:property name="tool_id">pondero</lticm:property>
          <lticm:property name="privacy_level">public</lticm:property>
          <lticm:property name="domain">#{host}</lticm:property>
          <lticm:options name="course_navigation">
            <lticm:property name="url">#{protocol}://#{host}/lti/launch</lticm:property>
            <lticm:property name="text">Pondero Journals</lticm:property>
            <lticm:property name="visibility">public</lticm:property>
            <lticm:property name="default">enabled</lticm:property>
            <lticm:property name="enabled">true</lticm:property>
          </lticm:options>
          <lticm:options name="assignment_selection">
            <lticm:property name="url">#{protocol}://#{host}/lti/launch</lticm:property>
            <lticm:property name="text">Pondero Journal</lticm:property>
            <lticm:property name="enabled">true</lticm:property>
          </lticm:options>
        </blti:extensions>
        
      </cartridge_basiclti_link>
    XML
  end
end
