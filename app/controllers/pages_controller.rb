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
    @terms = Term.all
    @articles = Article.all.order(publish_at: :desc).where("publish_at <= ?", Time.now)
    @tools = Tool.all
    @stocks = Stock.order(name: :asc)
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
