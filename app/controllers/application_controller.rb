class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  helper_method :current_user
  helper_method :user_signed_in?

  private

  def authenticate
    @current_user = nil
    authenticate_with_http_digest(ENV["AUTH_SECRET"]) do |username|
      @current_user = User.find_by(username: username)
      @current_user&.password_digest || false
    end
    !@current_user.nil?
  end

  def authenticate!
    authenticate || request_http_digest_authentication(ENV["AUTH_SECRET"])
  end

  def current_user
    Current.user ||= @current_user
  end

  def user_signed_in?
    Current.user.present?
  end
end
