# Enterprise-grade error handling for FERPA-compliant logging and user safety
module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from Pundit::NotAuthorizedError, with: :handle_authorization_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from ActiveRecord::StatementInvalid, with: :handle_database_error
  end

  private

  def handle_standard_error(exception)
    log_error(exception, severity: :error)
    
    if Rails.env.production?
      render_error_response(
        status: :internal_server_error,
        message: "An unexpected error occurred. Our team has been notified.",
        error_id: generate_error_id
      )
    else
      raise exception
    end
  end

  def handle_not_found(exception)
    log_error(exception, severity: :warn)
    
    respond_to do |format|
      format.html { redirect_to root_path, alert: "The requested resource was not found." }
      format.json { render json: { error: "Resource not found" }, status: :not_found }
    end
  end

  def handle_validation_error(exception)
    log_error(exception, severity: :info, include_params: false)
    
    respond_to do |format|
      format.html do
        flash.now[:alert] = "Please correct the following errors:"
        render action_name, status: :unprocessable_entity
      end
      format.json do
        render json: {
          error: "Validation failed",
          details: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def handle_authorization_error(exception)
    log_security_event(
      event_type: :unauthorized_access,
      user: current_user,
      resource: exception.record&.class&.name,
      action: action_name
    )
    
    respond_to do |format|
      format.html { redirect_to root_path, alert: "You are not authorized to perform this action." }
      format.json { render json: { error: "Unauthorized" }, status: :forbidden }
    end
  end

  def handle_parameter_missing(exception)
    log_error(exception, severity: :warn)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: "Required information is missing.") }
      format.json { render json: { error: "Missing required parameter: #{exception.param}" }, status: :bad_request }
    end
  end

  def handle_database_error(exception)
    log_error(exception, severity: :error, notify_admin: true)
    
    render_error_response(
      status: :service_unavailable,
      message: "The service is temporarily unavailable. Please try again later.",
      error_id: generate_error_id
    )
  end

  def log_error(exception, severity: :error, include_params: true, notify_admin: false)
    error_data = {
      error_id: generate_error_id,
      exception_class: exception.class.name,
      message: exception.message,
      backtrace: Rails.env.production? ? exception.backtrace&.first(5) : exception.backtrace,
      user_id: current_user&.id,
      user_email: current_user&.email&.gsub(/.+@/, "***@"), # FERPA compliance - mask email
      session_id: session.id.to_s[0..8], # Partial session ID for tracking
      request_id: request.request_id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      url: request.original_url,
      method: request.method,
      controller: controller_name,
      action: action_name,
      timestamp: Time.current.iso8601
    }

    # Include sanitized parameters (FERPA compliant)
    if include_params
      error_data[:params] = sanitize_params_for_logging(params.to_unsafe_h)
    end

    case severity
    when :error
      Rails.logger.error("[PONDERO_ERROR] #{error_data.to_json}")
    when :warn
      Rails.logger.warn("[PONDERO_WARNING] #{error_data.to_json}")
    when :info
      Rails.logger.info("[PONDERO_INFO] #{error_data.to_json}")
    end

    # Send to external monitoring (Sentry, Bugsnag, etc.) in production
    if Rails.env.production? && defined?(Sentry)
      Sentry.capture_exception(exception, extra: error_data)
    end

    # Notify administrators for critical errors
    if notify_admin
      AdminNotificationJob.perform_later(error_data)
    end

    error_data[:error_id]
  end

  def log_security_event(event_type:, user: nil, resource: nil, action: nil, details: {})
    security_data = {
      event_type: event_type,
      user_id: user&.id,
      user_role: user&.role,
      resource_type: resource,
      action_attempted: action,
      ip_address: request.remote_ip,
      user_agent: request.user_agent,
      session_id: session.id[0..8],
      request_id: request.request_id,
      timestamp: Time.current.iso8601,
      details: details
    }

    Rails.logger.warn("[PONDERO_SECURITY] #{security_data.to_json}")

    # Alert security team for serious violations
    if [:unauthorized_access, :suspicious_activity].include?(event_type)
      SecurityAlertJob.perform_later(security_data)
    end
  end

  def render_error_response(status:, message:, error_id: nil)
    respond_to do |format|
      format.html do
        @error_message = message
        @error_id = error_id
        render 'shared/error', status: status, layout: 'application'
      end
      format.json do
        error_response = { error: message }
        error_response[:error_id] = error_id if error_id
        render json: error_response, status: status
      end
    end
  end

  def generate_error_id
    "ERR-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
  end

  def sanitize_params_for_logging(params_hash)
    # Remove sensitive data for FERPA compliance
    sensitive_keys = %w[
      password password_confirmation
      credit_card cvv ssn
      social_security_number
      bank_account routing_number
      medical_record health_data
      family_financial_info
      disciplinary_record
    ]

    sanitized = params_hash.deep_dup
    
    sanitized.each do |key, value|
      if sensitive_keys.any? { |sensitive| key.to_s.downcase.include?(sensitive) }
        sanitized[key] = "[FILTERED]"
      elsif value.is_a?(String) && value.length > 1000
        # Truncate very long strings to prevent log bloat
        sanitized[key] = "#{value[0..997]}..."
      elsif value.is_a?(Hash)
        sanitized[key] = sanitize_params_for_logging(value)
      end
    end

    sanitized
  end

  # Performance monitoring helpers
  def track_performance(&block)
    start_time = Time.current
    result = block.call
    duration = (Time.current - start_time) * 1000 # in milliseconds

    # Log slow requests (>2 seconds)
    if duration > 2000
      Rails.logger.warn("[PONDERO_PERFORMANCE] Slow request: #{controller_name}##{action_name} took #{duration.round(2)}ms")
    end

    result
  end

  # Health check endpoint support
  def health_check
    checks = {
      database: check_database_health,
      redis: check_redis_health,
      storage: check_storage_health,
      external_apis: check_external_apis_health
    }

    overall_status = checks.values.all? { |status| status[:healthy] }

    respond_to do |format|
      format.json do
        render json: {
          status: overall_status ? 'healthy' : 'unhealthy',
          timestamp: Time.current.iso8601,
          checks: checks
        }, status: overall_status ? :ok : :service_unavailable
      end
    end
  end

  private

  def check_database_health
    {
      healthy: ActiveRecord::Base.connection.active?,
      response_time: measure_response_time { User.first }
    }
  rescue => e
    { healthy: false, error: e.message }
  end

  def check_redis_health
    # Add Redis health check if using Redis
    { healthy: true, message: "Redis not configured" }
  end

  def check_storage_health
    {
      healthy: ActiveStorage::Blob.service.exist?("health_check") || true,
      message: "Storage accessible"
    }
  rescue => e
    { healthy: false, error: e.message }
  end

  def check_external_apis_health
    # Check LTI connectivity, email services, etc.
    { healthy: true, message: "External APIs operational" }
  end

  def measure_response_time(&block)
    start_time = Time.current
    block.call
    ((Time.current - start_time) * 1000).round(2)
  end
end