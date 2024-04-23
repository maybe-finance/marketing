require "net/http"
require "json"

class PagesController < ApplicationController
  def index
    @stargazers_count = Rails.cache.fetch("stargazers_count", expires_in: 24.hours) do
      fetch_stargazers_count
    end
  end

  private

  def fetch_stargazers_count
    url = URI("https://ungh.cc/repos/maybe-finance/maybe")
    response = Net::HTTP.get(url)
    json = JSON.parse(response)
    json["repo"]["stars"]
  rescue StandardError => e
    Rails.logger.error "Failed to fetch stargazers count: #{e.message}"
    nil
  end
end
