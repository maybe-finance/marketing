# This controller handles requests for stock information.
# It fetches stock data from the Synth Finance API for a given stock ticker.
class Stocks::InfoController < ApplicationController
  # GET /stocks/:stock_ticker/info
  # Retrieves and displays information for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock (passed in the URL)
  # @return [Object] Sets @stock and @stock_info instance variables for use in the view
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    # Fetch stock information from Synth Finance API
    @stock_info = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}", nil, headers)
    @stock_info = JSON.parse(@stock_info.body)["data"]
  end
end
