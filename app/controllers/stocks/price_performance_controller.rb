# This controller handles requests for stock price performance data.
# It fetches real-time and historical data from an external API (Synth Finance)
# and returns the price performance information for a given stock.
class Stocks::PricePerformanceController < ApplicationController
  # GET /stocks/:stock_ticker/price_performance
  # Retrieves and returns the price performance data for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock
  # @param timeframe [String] The timeframe for historical data (default: "24h")
  # @return [JSON] Price performance data including low, high, and current prices
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])
    timeframe = params[:timeframe] || "24h"

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    # Fetch real-time data
    @real_time_data = fetch_real_time_data(@stock.symbol, headers)

    if @real_time_data.nil?
      @price_performance = { error: "Unable to fetch real-time data" }
    elsif timeframe == "24h"
      @price_performance = {
        low: @real_time_data["low"],
        high: @real_time_data["high"],
        current: @real_time_data["fair_market_value"]
      }
    else
      # Fetch historical data based on timeframe
      @historical_data = fetch_historical_data(@stock.symbol, timeframe, headers)

      if @historical_data.nil?
        @price_performance = { error: "Unable to fetch historical data" }
      else
        @price_performance = {
          low: @historical_data[:low],
          high: @historical_data[:high],
          current: @real_time_data["fair_market_value"]
        }
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @price_performance }
    end
  end

  private

  # Fetches real-time stock data from the Synth Finance API
  #
  # @param symbol [String] The stock symbol
  # @param headers [Hash] HTTP headers for the API request
  # @return [Hash, nil] Real-time stock data or nil if the request fails
  def fetch_real_time_data(symbol, headers)
    response = Faraday.get("https://api.synthfinance.com/tickers/#{symbol}/real-time", nil, headers)
    return nil unless response.success?
    JSON.parse(response.body)["data"]
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("Error fetching real-time data: #{e.message}")
    nil
  end

  # Fetches historical stock data from the Synth Finance API
  #
  # @param symbol [String] The stock symbol
  # @param timeframe [String] The timeframe for historical data
  # @param headers [Hash] HTTP headers for the API request
  # @return [Hash, nil] Historical stock data or nil if the request fails
  def fetch_historical_data(symbol, timeframe, headers)
    end_date = Date.today
    start_date = calculate_start_date(timeframe)

    response = Faraday.get(
      "https://api.synthfinance.com/tickers/#{symbol}/open-close",
      {
        start_date: start_date.iso8601,
        end_date: end_date.iso8601,
        interval: "day"
      },
      headers
    )

    return nil unless response.success?

    data = JSON.parse(response.body)
    prices = data["prices"].map { |p| p["close"].to_f }

    return nil if prices.empty?

    {
      low: prices.min,
      high: prices.max
    }
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("Error fetching historical data: #{e.message}")
    nil
  end

  # Calculates the start date based on the given timeframe
  #
  # @param timeframe [String] The timeframe for historical data
  # @return [Date] The calculated start date
  def calculate_start_date(timeframe)
    case timeframe
    when "24h"
      1.day.ago
    when "7d"
      7.days.ago
    when "30d"
      30.days.ago
    when "1y"
      1.year.ago
    else
      1.day.ago
    end
  end
end
