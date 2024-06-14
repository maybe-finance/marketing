class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.find_by(slug: params[:id])
    @loan_interest_rate = fetch_mortgage_rate("MORTGAGE30US")
  end

  private

  def fetch_mortgage_rate(mortgage_duration)
    redis = Redis.new
    cache_key = "mortgage_rate_#{mortgage_duration}"

    cached_response = redis.get(cache_key)
    return cached_response if cached_response

    response = HTTParty.get("https://api.stlouisfed.org/fred/series/observations?series_id=#{mortgage_duration}&api_key=#{ENV['FRED_API_KEY']}&file_type=json&limit=1&sort_order=desc&frequency=w")
    if response.success?
      observations_value = JSON.parse(response.body)["observations"].first["value"]
      redis.set(cache_key, observations_value)
      redis.expire(cache_key, 24.hours.to_i)
      observations_value
    else
      nil
    end
  end
end
