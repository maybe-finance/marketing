class Stocks::PricePerformanceController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])
    timeframe = params[:timeframe] || '24h'

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
    elsif timeframe == '24h'
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

  def fetch_real_time_data(symbol, headers)
    response = Faraday.get("https://api.synthfinance.com/tickers/#{symbol}/real-time", nil, headers)
    return nil unless response.success?
    JSON.parse(response.body)["data"]
  rescue Faraday::Error, JSON::ParserError => e
    Rails.logger.error("Error fetching real-time data: #{e.message}")
    nil
  end

  def fetch_historical_data(symbol, timeframe, headers)
    end_date = Date.today
    start_date = calculate_start_date(timeframe)

    response = Faraday.get(
      "https://api.synthfinance.com/tickers/#{symbol}/open-close",
      {
        start_date: start_date.iso8601,
        end_date: end_date.iso8601,
        interval: 'day'
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

  def calculate_start_date(timeframe)
    case timeframe
    when '24h'
      1.day.ago
    when '7d'
      7.days.ago
    when '30d'
      30.days.ago
    when '1y'
      1.year.ago
    else
      1.day.ago
    end
  end
end
