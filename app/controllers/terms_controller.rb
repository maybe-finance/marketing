class TermsController < ApplicationController
  def index
    @query = params[:q]

    @terms = Term.all
    @terms = @terms.where("name ILIKE :query OR title ILIKE :query", query: "%#{@query}%") if @query.present?
  end

  def show
    @term = Term.find_by(slug: params[:id])
  end
end
