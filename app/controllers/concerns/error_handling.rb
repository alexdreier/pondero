module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
  end

  private

  def handle_standard_error(exception)
    Rails.logger.error "Unexpected error: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")

    respond_to do |format|
      format.html do
        flash[:error] = "An unexpected error occurred. Please try again."
        redirect_back(fallback_location: root_path)
      end
      format.json do
        render json: { 
          error: "An unexpected error occurred", 
          message: Rails.env.development? ? exception.message : "Please try again"
        }, status: :internal_server_error
      end
    end
  end

  def handle_not_found(exception)
    Rails.logger.warn "Record not found: #{exception.message}"

    respond_to do |format|
      format.html do
        flash[:error] = "The requested resource was not found."
        redirect_to root_path
      end
      format.json do
        render json: { error: "Resource not found" }, status: :not_found
      end
    end
  end

  def handle_validation_error(exception)
    Rails.logger.warn "Validation error: #{exception.message}"

    respond_to do |format|
      format.html do
        flash[:error] = "Please correct the following errors: #{exception.record.errors.full_messages.join(', ')}"
        redirect_back(fallback_location: root_path)
      end
      format.json do
        render json: { 
          error: "Validation failed",
          errors: exception.record.errors.full_messages
        }, status: :unprocessable_entity
      end
    end
  end

  def handle_parameter_missing(exception)
    Rails.logger.warn "Parameter missing: #{exception.message}"

    respond_to do |format|
      format.html do
        flash[:error] = "Required information is missing. Please try again."
        redirect_back(fallback_location: root_path)
      end
      format.json do
        render json: { 
          error: "Required parameter missing",
          parameter: exception.param
        }, status: :bad_request
      end
    end
  end

  def handle_access_denied(message = "You don't have permission to access this resource.")
    respond_to do |format|
      format.html do
        flash[:error] = message
        redirect_to root_path
      end
      format.json do
        render json: { error: message }, status: :forbidden
      end
    end
  end
end