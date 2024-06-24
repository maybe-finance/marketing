class StocksController < ApplicationController
  def index
    tickers = params[:tickers]
    if tickers.nil? || tickers.empty?
      render json: { error: "No tickers provided" }, status: :bad_request
      return
    end

    stock_data = fetch_stock_data(tickers)
    render json: stock_data
  end

  def show
  end

  private

  def make_stock_data_cache_key(query)
    query_string = URI.encode_www_form(query)
    "stock_data__#{query_string}"
  end

  def cache_stock_data(cache_key, data, redis)
    redis.set(cache_key, data)
    redis.expire(cache_key, 24.hours.to_i)
  end

  def fetch_stock_data(tickers)
    redis = Redis.new
    token = ENV["TWELVE_DATA_API_KEY"]
    base_url = "https://api.twelvedata.com/time_series"
    stock_data = []

    end_date = Date.today
    start_date = end_date << 12 * 25

    query = {
      format: "JSON",
      interval: "1month",
      apikey: token,
      start_date: start_date.to_s,
      end_date: end_date.to_s
    }

    tickers.each do |ticker|
      query[:symbol] = ticker
      cache_key = make_stock_data_cache_key(query)

      cached_response = redis.get(cache_key)
      puts "cached_response: #{cached_response}"
      if cached_response
        stock_data << { ticker: ticker, data: JSON.parse(cached_response) }
        next
      end

      response = HTTParty.get(base_url, query: query)

      if response.success?
        # cache the response
        values = response.parsed_response["values"]
        cache_stock_data(cache_key, values, redis)
        stock_data << { ticker: ticker, data: values }
      else
        # RETHINK THIS AND POTENTIALLY handle errors better
        stock_data << { ticker: ticker, error: response.message }
      end
    end

    stock_data
  end
end
