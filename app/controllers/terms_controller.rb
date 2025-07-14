# TermsController handles requests related to Term objects.
# It provides functionality for listing and showing individual terms.
class TermsController < ApplicationController
  # GET /terms
  # Lists all terms, optionally filtered by a search query.
  #
  # @param q [String] Optional search query to filter terms by name or title
  # @return [Array<Term>] Collection of Term objects
  #
  # @example
  #   GET /terms
  #   GET /terms?q=ruby
  def index
    @query = params[:q]

    @terms = Term.order(:name)
    @terms = @terms.where("name ILIKE :query OR title ILIKE :query", query: "%#{@query}%") if @query.present?
  end

  # GET /terms/:id
  # Displays a specific term based on its slug.
  #
  # @param id [String] The slug of the term to display
  # @return [Term] The requested Term object
  #
  # @example
  #   GET /terms/ruby-on-rails
  def show
    @term = Term.includes(authorship: :author).find_by(slug: params[:id])

    if @term.nil?
      redirect_to terms_path, alert: "The financial term you're looking for could not be found."
    end
  end
end
