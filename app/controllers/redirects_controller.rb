class RedirectsController < ApplicationController
  skip_before_action :check_for_redirects

  def catch_all
    redirect_rule = find_matching_redirect(request.path)

    if redirect_rule
      destination = redirect_rule.process_destination(request.path)
      redirect_to destination, status: redirect_rule.status_code
    else
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
  end

  private

  def find_matching_redirect(request_path)
    Redirect.active.by_priority.find do |redirect|
      redirect.matches_path?(request_path)
    end
  end
end
