class ApplicationController < ActionController::Base
  include SentryContext
  include Redirectable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern
  default_form_builder ApplicationFormBuilder

  rescue_from StandardError do |e|
    Rails.logger.error "[500 ERROR] #{request.method} #{request.fullpath}"
    Rails.logger.error "#{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.take(10).join("\\n")
    Sentry.capture_exception(e) if defined?(Sentry)
    raise e
  end
end
