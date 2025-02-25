# TermsController handles requests related to Term objects.
# It provides functionality for listing and showing individual terms.
class TermsController < ApplicationController
  # Skip session for these actions to improve caching with CDNs like Cloudflare
  skip_before_action :verify_authenticity_token, only: [ :index, :show ]

  # Completely disable cookies/session for these cacheable actions
  before_action :disable_session, only: [ :index, :show ]

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
    fresh_when(etag: "terms-index-#{Term.maximum(:updated_at)&.to_i || 0}-#{@query}")

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
    @term = Term.find_by(slug: params[:id])

    if @term
      expires_in 12.hours, public: true
      fresh_when(etag: "term-#{@term.id}-#{@term.updated_at.to_i}")
    end
  end

  private

  # Completely disable the session to prevent cookies from being set
  # This improves cacheability with CDNs like Cloudflare
  def disable_session
    # Multiple approaches to ensure session is disabled
    request.session_options[:skip] = true

    # Also disable cookies
    request.session_options[:defer] = true
    request.session_options[:id] = nil

    # Clear cookies if they exist
    cookies.clear if request.cookies.present?

    # Set Cache-Control header explicitly
    response.headers["Cache-Control"] = "public, max-age=43200"
  end
end
