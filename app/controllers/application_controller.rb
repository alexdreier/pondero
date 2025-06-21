class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Pundit::Authorization
  include ErrorHandling
  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_current_user_for_logging
  before_action :check_maintenance_mode

  # Enterprise logging and monitoring
  around_action :track_performance

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def set_current_user_for_logging
    # Set current user context for logging (FERPA compliant)
    # Skip RequestStore for demo - would use in production for thread-safe user context
  end

  def check_maintenance_mode
    # Skip maintenance mode check for development
    return unless Rails.env.production?
    
    if Rails.application.config.respond_to?(:maintenance_mode) && Rails.application.config.maintenance_mode
      unless current_user&.administrator?
        render 'shared/maintenance', status: :service_unavailable, layout: 'application'
      end
    end
  end

  # Auto-save support for enterprise reliability
  def handle_auto_save_request
    if params[:auto_save] == 'true'
      # Process auto-save differently - no redirects, minimal validation
      yield if block_given?
      
      respond_to do |format|
        format.json { render json: { status: 'saved', timestamp: Time.current.iso8601 } }
        format.html { head :ok }
      end
    else
      yield if block_given?
    end
  end

  # FERPA-compliant user activity logging
  def log_user_activity(action_type, resource = nil, details = {})
    return unless current_user

    activity_data = {
      user_id: current_user.id,
      user_role: current_user.role,
      action_type: action_type,
      resource_type: resource&.class&.name,
      resource_id: resource&.id,
      controller: controller_name,
      action: action_name,
      ip_address: request.remote_ip,
      session_id: session.id[0..8],
      timestamp: Time.current.iso8601,
      details: details
    }

    Rails.logger.info("[PONDERO_ACTIVITY] #{activity_data.to_json}")
    
    # Store in database for audit trail if needed
    UserActivityLog.create!(activity_data) if defined?(UserActivityLog)
  end

  # Performance tracking for enterprise monitoring
  def track_performance
    start_time = Time.current
    yield
    duration = ((Time.current - start_time) * 1000).round(2)
    Rails.logger.info("[PONDERO_PERFORMANCE] #{controller_name}##{action_name} completed in #{duration}ms")
  end

  # Temporary fix endpoint - remove after use
  def fix_journals
    return render plain: "Access denied" unless current_user&.administrator?
    
    journals_updated = 0
    Journal.where(published: true, access_level: 'restricted').find_each do |journal|
      journal.update!(access_level: 'open')
      journals_updated += 1
    end
    
    render plain: "Updated #{journals_updated} journals from 'restricted' to 'open' access_level. Start Journal buttons should now work."
  end

  # Content Security Policy for enhanced security
  def set_content_security_policy
    response.headers['Content-Security-Policy'] = [
      "default-src 'self'",
      "script-src 'self' 'unsafe-inline' 'unsafe-eval'", # Needed for Trix editor
      "style-src 'self' 'unsafe-inline'",
      "img-src 'self' data: blob:",
      "font-src 'self' data:",
      "connect-src 'self'",
      "media-src 'self'",
      "object-src 'none'",
      "frame-ancestors 'self'",
      "base-uri 'self'",
      "form-action 'self'"
    ].join('; ')
  end
end
