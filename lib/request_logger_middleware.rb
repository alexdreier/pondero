class RequestLoggerMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    Rails.logger.error "!!! MIDDLEWARE: #{request.request_method} #{request.fullpath} !!!"
    @app.call(env)
  end
end