module SentryContext
  extend ActiveSupport::Concern

  included do
    before_action :set_sentry_context
  end

  private

  def set_sentry_context
    # Set user context with IP address for anonymous visitors
    Sentry.set_user(ip_address: request.remote_ip)

    # You can add additional context as needed
    Sentry.set_context(
      "request_details", {
        url: request.url,
        method: request.method,
        referer: request.referer,
        user_agent: request.user_agent
      }
    )
  end
end
