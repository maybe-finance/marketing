# PagesController handles various static and dynamic pages in the application.
# It includes methods for the home page, terms of service, privacy policy, and sitemap.
# The controller also fetches and caches the stargazers count from GitHub for the Maybe Finance repository.

require "net/http"
require "json"

class PagesController < ApplicationController
  # GET /
  # Renders the home page and displays the number of GitHub stars for the Maybe Finance repository.
  # The star count is cached for 24 hours to reduce API calls.
  #
  # @return [Integer, nil] The number of GitHub stars or nil if fetching fails
  def index
    @stars = Rails.cache.fetch("stargazers_count", expires_in: 24.hours) do
      fetch_stars_count
    end
  end

  # GET /tos
  # Renders the Terms of Service page.
  def tos
  end

  # GET /privacy
  # Renders the Privacy Policy page.
  def privacy
  end

  # GET /sitemap
  # Generates a sitemap with links to various resources in the application.
  # Includes terms, articles, tools, and stocks.
  #
  # @return [Array<Term>, Array<Article>, Array<Tool>, Array<Stock>] Collections of resources for the sitemap
  def sitemap
    @page = (params[:page] || 1).to_i
    @terms = Term.all
    @articles = Article.all.order(publish_at: :desc).where("publish_at <= ?", Time.now)
    @tools = Tool.all
    @exchanges = Stock.where(kind: "stock")
                     .where.not(mic_code: nil)
                     .distinct
                     .pluck(:exchange, :country_code)
                     .compact
                     .group_by(&:first)
                     .transform_values(&:first)
                     .values
                     .sort_by(&:first)
    @industries = Stock.where(kind: "stock").where.not(mic_code: nil).where.not(industry: nil).distinct.pluck(:industry, :country_code).compact.sort_by(&:first)
    @sectors = Stock.where(kind: "stock").where.not(mic_code: nil).where.not(sector: nil).distinct.pluck(:sector).compact.sort
    @exchange_rate_currencies = Tool::Presenter::ExchangeRateCalculator.new.currency_options

    # Paginate stocks
    @stocks = Stock.order(name: :asc)
                   .where.not(mic_code: nil)
                   .offset((@page - 1) * 45_000)
                   .limit(45_000)

    respond_to do |format|
      format.xml
    end
  end

  # GET /sitemap.xml
  # Generates a sitemap index file with links to multiple sitemaps.
  #
  # @return [XML] Sitemap index file
  def sitemap_index
    @total_stocks = Stock.where.not(mic_code: nil).count
    @sitemap_count = (@total_stocks / 45_000.0).ceil # Using 45k to leave room for other URLs

    respond_to do |format|
      format.xml
    end
  end

  private

  # Fetches the current number of stars for the Maybe Finance GitHub repository.
  # Uses the ungh.cc API to retrieve the star count.
  #
  # @return [Integer, nil] The number of stars or nil if there's an error during the API call
  # @example
  #   fetch_stars_count # => 1234
  def fetch_stars_count
    url = URI("https://ungh.cc/repos/maybe-finance/maybe")
    response = Net::HTTP.get(url)
    json = JSON.parse(response)
    json["repo"]["stars"]
  rescue StandardError => e
    Rails.logger.error "Failed to fetch stars count: #{e.message}"
    nil
  end
end
