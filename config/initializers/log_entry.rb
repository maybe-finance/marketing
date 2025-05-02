# config/initializers/log_entry.rb
class LogIncomingRequest
  def initialize(app)
    @app = app
  end

  def call(env)
    req = Rack::Request.new(env)
    Rails.logger.info "[ENTRY] #{req.request_method} #{req.fullpath} -- #{req.env['HTTP_X_REQUEST_ID']}"
    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before(0, LogIncomingRequest)
