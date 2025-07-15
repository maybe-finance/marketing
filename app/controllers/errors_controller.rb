class ErrorsController < ApplicationController
  skip_before_action :set_public_cache

  def show
    exception = request.env["action_dispatch.exception"]
    status_code = ActionDispatch::ExceptionWrapper.new(request.env, exception).status_code
    
    # Force HTML format for error pages unless explicitly requesting another format
    request.format = :html if request.format.symbol == :text || request.format.symbol == :all
    
    respond_to do |format|
      format.html do
        case status_code
        when 404
          render "not_found", status: :not_found, formats: [:html]
        when 422
          render "unprocessable_entity", status: :unprocessable_entity, formats: [:html]
        when 500
          render "internal_server_error", status: :internal_server_error, formats: [:html]
        else
          render "internal_server_error", status: :internal_server_error, formats: [:html]
        end
      end
      format.json { render json: { error: status_code }, status: status_code }
      format.any do
        head status_code
      end
    end
  end

  def not_found
    request.format = :html if request.format.symbol == :text || request.format.symbol == :all
    respond_to do |format|
      format.html { render status: :not_found, formats: [:html] }
      format.json { render json: { error: "Not found" }, status: :not_found }
      format.any { head :not_found }
    end
  end

  def internal_server_error
    request.format = :html if request.format.symbol == :text || request.format.symbol == :all
    respond_to do |format|
      format.html { render status: :internal_server_error, formats: [:html] }
      format.json { render json: { error: "Internal server error" }, status: :internal_server_error }
      format.any { head :internal_server_error }
    end
  end

  def unprocessable_entity
    request.format = :html if request.format.symbol == :text || request.format.symbol == :all
    respond_to do |format|
      format.html { render status: :unprocessable_entity, formats: [:html] }
      format.json { render json: { error: "Unprocessable entity" }, status: :unprocessable_entity }
      format.any { head :unprocessable_entity }
    end
  end
end