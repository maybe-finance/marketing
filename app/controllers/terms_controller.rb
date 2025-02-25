# TermsController handles requests related to Term objects.
# It provides functionality for listing and showing individual terms.
class TermsController < ApplicationController
  # Skip session for these actions to improve caching with CDNs like Cloudflare
  skip_before_action :verify_authenticity_token, only: [ :index, :show ]

  # Disable cookies/session for these cacheable actions
  before_action :skip_session, only: [ :index, :show ]

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
    expires_in 12.hours, public: true
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
    expires_in 12.hours, public: true
    @term = Term.find_by(slug: params[:id])
  end

  private

  # Skip the session to prevent cookies from being set
  # This improves cacheability with CDNs like Cloudflare
  def skip_session
    request.session_options[:skip] = true
  end
end
