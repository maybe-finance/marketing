class ErrorsController < ApplicationController
  skip_before_action :set_public_cache

  def show
    exception = request.env["action_dispatch.exception"]
    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    
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

  def not_found
    render status: :not_found
  end

  def internal_server_error
    render status: :internal_server_error
  end

  def unprocessable_entity
    render status: :unprocessable_entity
  end
end