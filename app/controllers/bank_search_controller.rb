class BankSearchController < ApplicationController
  def index
    # Main search page - will render the search interface
    @total_institutions = Institution.count
    @countries = Institution.distinct.pluck("unnest(country_codes)").compact.sort
  end

  def search
    # AJAX endpoint for search functionality
    query = params[:query]&.strip
    country = params[:country]&.strip
    page = params[:page]&.to_i || 1
    per_page = [ params[:per_page]&.to_i || 20, 50 ].min # Max 50 results per page

    # Start with base scope
    institutions = Institution.all

    # Apply search filters
    institutions = apply_search_filters(institutions, query, country)

    # Apply pagination
    total_count = institutions.count
    institutions = institutions.offset((page - 1) * per_page).limit(per_page)

    # Prepare response data
    response_data = {
      institutions: institutions.map(&:to_search_result),
      pagination: {
        current_page: page,
        per_page: per_page,
        total_count: total_count,
        total_pages: (total_count.to_f / per_page).ceil,
        has_next: page * per_page < total_count,
        has_prev: page > 1
      },
      filters: {
        query: query,
        country: country
      },
      search_time: Time.current.iso8601
    }

    render json: response_data, status: :ok

  rescue => e
    Rails.logger.error "Institution search error: #{e.message}"
    render json: {
      error: "Search failed",
      message: "An error occurred while searching institutions"
    }, status: :internal_server_error
  end

  private

  def apply_search_filters(scope, query, country)
    # Apply name search if query provided
    if query.present?
      scope = scope.search_by_name(query)
    end

    # Apply country filter if provided
    if country.present?
      scope = scope.by_country(country)
    end

    # Default ordering by name for consistent results
    scope.order(:name)
  end

  def plaid_client_available?
    PlaidConfig.client.present?
  rescue => e
    Rails.logger.error "Plaid client error: #{e.message}"
    false
  end
end
