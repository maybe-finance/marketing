class Stocks::ChartController < ApplicationController
  def show
    Rails.logger.info "Chart#show called with params: #{params.inspect}"
    @stock = Stock.find_by(symbol: params[:stock_ticker])
    
    Rails.logger.info "Received request for stock: #{@stock&.symbol}, time_range: #{params[:time_range]}"

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}"
    }

    end_date = Date.today
    start_date = calculate_start_date(params[:time_range])
    
    Rails.logger.info "Calculated date range: #{start_date} to #{end_date}"

    response = Faraday.get(
      "https://api.synthfinance.com/tickers/#{@stock.symbol}/open-close",
      { start_date: start_date.iso8601, end_date: end_date.iso8601 },
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
      format.json { 
        Rails.logger.info "Responding with JSON: #{@stock_chart.to_json}"
        render json: @stock_chart 
      }
    end
  end

  private

  def calculate_start_date(time_range)
    case time_range
    when "1D" then Date.today - 1.day
    when "1W" then Date.today - 1.week
    when "1M" then Date.today - 1.month
    when "3M" then Date.today - 3.months
    when "6M" then Date.today - 6.months
    when "1Y" then Date.today - 1.year
    when "5Y" then Date.today - 5.years
    else Date.today - 30.days  # Default to 30 days
    end
  end
end