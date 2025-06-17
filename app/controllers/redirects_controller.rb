class RedirectsController < ApplicationController
  skip_before_action :check_for_redirects

  def catch_all
    redirect_rule = find_matching_redirect(request.path)

    if redirect_rule
      destination = redirect_rule.process_destination(request.path)
      redirect_to destination, status: redirect_rule.status_code
    else
      render file: Rails.root.join("public", "404.html"), status: :not_found, layout: false
    end
  end

  private

  def find_matching_redirect(request_path)
    Redirect.active.by_priority.find do |redirect|
      redirect.matches_path?(request_path)
    end
  end
end
