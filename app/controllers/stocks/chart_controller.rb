# This controller handles the generation of stock charts for the Maybe Finance application.
# It fetches stock data from the Synth Finance API and processes it to create a chart
# with price information for a given stock over a specified time range.

class Stocks::ChartController < ApplicationController
  # GET /stocks/:stock_ticker/chart
  # Retrieves and processes stock data to generate a chart
  #
  # @param stock_ticker [String] The ticker symbol of the stock
  # @param time_range [String] The time range for the chart (e.g., "1M", "3M", "6M", "1Y", "5Y")
  # @return [JSON] A JSON object containing chart data or an error message
  def show
    if params[:stock_ticker].include?(":")
      symbol, mic_code = params[:stock_ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:stock_ticker], country_code: "US")
    end

    # return redirect_to stocks_path if @stock.nil?

    time_range = params[:time_range].presence || "1M"  # Set default if nil or empty

    @stock_chart = Rails.cache.fetch("stock_chart/v2/#{@stock.symbol}:#{@stock.mic_code}/#{time_range}", expires_in: 12.hours) do
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
        "X-Source" => "maybe_marketing",
        "X-Source-Type" => "api"
      }

      end_date = Date.today
      start_date, interval = calculate_start_date_and_interval(time_range)

      response = Faraday.get(
        "https://api.synthfinance.com/tickers/#{@stock.symbol}/open-close?mic_code=#{@stock.mic_code}",
        {
          start_date: start_date.iso8601,
          end_date: end_date.iso8601,
          interval: interval,
          limit: 500
        },
        headers
      )

      if response.success?
        data = JSON.parse(response.body)
        valid_prices = data["prices"].reject { |p| p["no_data"] || p["close"].nil? || p["open"].nil? }

        if valid_prices.any?
          latest_price = valid_prices.last["close"].to_f
          first_price = valid_prices.first["open"].to_f
          price_change = (latest_price - first_price).round(2)
          price_change_percentage = ((price_change / first_price) * 100).round(2)
          currency = data["currency"] || "USD"  # Default to USD if not provided
        else
          latest_price = price_change = price_change_percentage = 0
          currency = "USD"
        end

        {
          latest_price: latest_price,
          price_change: price_change,
          price_change_percentage: price_change_percentage,
          currency: currency,
          prices: valid_prices
        }
      else
        { error: "Unable to fetch stock data" }
      end
    end

    respond_to do |format|
      format.html
      format.json { render json: @stock_chart }
    end
  end

  private

  # Calculates the start date and interval based on the given time range
  #
  # @param time_range [String] The time range for the chart (e.g., "1M", "3M", "6M", "1Y", "5Y")
  # @return [Array<Date, String>] An array containing the start date and interval
  def calculate_start_date_and_interval(time_range)
    case time_range
    when "1M"
      [ Date.today - 1.month, "day" ]
    when "3M"
      [ Date.today - 3.months, "week" ]
    when "6M"
      [ Date.today - 6.months, "week" ]
    when "1Y"
      [ Date.today - 1.year, "month" ]
    when "5Y"
      [ Date.today - 5.years, "month" ]
    else
      [ Date.today - 1.month, "day" ]  # Default to 1 month with daily interval
    end
  end
end
