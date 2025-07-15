class ApplicationController < ActionController::Base
  before_action :set_public_cache

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

  def not_found
    respond_to do |format|
      format.html do
        if Rails.env.production? || Rails.env.development?
          render "errors/not_found", status: :not_found
        else
          render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false
        end
      end
      format.json { head :not_found }
      format.any { head :not_found }
    end
  end

  private

  def set_public_cache
    response.headers["Cache-Control"] = "public, max-age=3600"
  end
end
