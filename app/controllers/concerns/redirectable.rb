module Redirectable
  extend ActiveSupport::Concern

  included do
    before_action :check_for_redirects
  end

  private

  def check_for_redirects
    return if request.post? || request.patch? || request.put? || request.delete?

    redirect_rule = find_matching_redirect(request.path)

    if redirect_rule
      destination = redirect_rule.process_destination(request.path)
      redirect_to destination, status: redirect_rule.status_code
    end
  end

  def find_matching_redirect(request_path)
    Redirect.active.by_priority.find do |redirect|
      redirect.matches_path?(request_path)
    end
  end
end
