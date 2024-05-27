require "net/http"
require "json"

class PagesController < ApplicationController
  def index
    @stars = Rails.cache.fetch("stargazers_count", expires_in: 24.hours) do
      fetch_stars_count
    end
  end

  def tos
  end

  def privacy
  end

  def sitemap
    @terms = Term.all
    @articles = Article.all.order(publish_at: :desc).where("publish_at <= ?", Time.now)
  end

  private

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
