class TermsController < ApplicationController
  def index
    @query = params[:q]

    @terms = Term.all
    @terms = @terms.where("title ILIKE ?", "%#{@query}%") if @query.present?
  end

  def show
    @term = Term.find(params[:id])
  end
end
