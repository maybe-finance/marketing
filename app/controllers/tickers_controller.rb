# This controller handles requests related to stock ticker data.
# It interacts with the Synth Finance API to fetch open and close prices for specified tickers.
class TickersController < ApplicationController
  # Fetches open and close prices for multiple tickers within a specified date range.
  #
  # @param tickers [String] A comma-separated string of stock ticker symbols.
  # @param start_date [String] The start date for the price data in YYYY-MM-DD format.
  # @param end_date [String] The end date for the price data in YYYY-MM-DD format.
  #
  # @return [JSON] An array of hashes, each containing a ticker symbol and its corresponding price data.
  #
  # @example
  #   GET /tickers/open_close?tickers=AAPL,TSLA&start_date=2023-01-01&end_date=2023-12-31
  def open_close
    tickers = params[:tickers].split(",")
    start_date = params[:start_date]
    end_date = params[:end_date]

    results = tickers.map do |ticker|
      response = Faraday.get(
        "https://api.synthfinance.com/tickers/#{ticker}/open-close",
        { start_date: start_date, end_date: end_date, interval: "month", limit: 500 },
        { "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}" }
      )

      { ticker => JSON.parse(response.body)["prices"] }
    end

    render json: results
  end
end
