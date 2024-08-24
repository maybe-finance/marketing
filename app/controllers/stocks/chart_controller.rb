class Stocks::ChartController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])
    
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    end_date = Date.today
    start_date, interval = calculate_start_date_and_interval(params[:time_range])
    
    response = Faraday.get(
      "https://api.synthfinance.com/tickers/#{@stock.symbol}/open-close",
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
      else
        latest_price = price_change = price_change_percentage = 0
      end

      @stock_chart = {
        latest_price: latest_price,
        price_change: price_change,
        price_change_percentage: price_change_percentage,
        prices: valid_prices
      }
    else
      @stock_chart = { error: "Unable to fetch stock data" }
    end

    respond_to do |format|
      format.html
      format.json { render json: @stock_chart }
    end
  end

  private

  def calculate_start_date_and_interval(time_range)
    case time_range
    when "1M"
      [Date.today - 1.month, "day"]
    when "3M"
      [Date.today - 3.months, "week"]
    when "6M"
      [Date.today - 6.months, "week"]
    when "1Y"
      [Date.today - 1.year, "month"]
    when "5Y"
      [Date.today - 5.years, "month"]
    else
      [Date.today - 1.month, "day"]  # Default to 1 month with daily interval
    end
  end
end