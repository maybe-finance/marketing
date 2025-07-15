class ErrorsController < ApplicationController
  skip_before_action :set_public_cache

  def show
    exception = request.env["action_dispatch.exception"]
    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    
    respond_to do |format|
      format.html do
        case status_code
        when 404
          render "not_found", status: :not_found
        when 422
          render "unprocessable_entity", status: :unprocessable_entity
        when 500
          render "internal_server_error", status: :internal_server_error
        else
          render "internal_server_error", status: :internal_server_error
        end
      end
      format.any do
        head status_code
      end
    end
  end

  def not_found
    respond_to do |format|
      format.html { render status: :not_found }
      format.any { head :not_found }
    end
  end

  def internal_server_error
    respond_to do |format|
      format.html { render status: :internal_server_error }
      format.any { head :internal_server_error }
    end
  end

  def unprocessable_entity
    respond_to do |format|
      format.html { render status: :unprocessable_entity }
      format.any { head :unprocessable_entity }
    end
  end
end