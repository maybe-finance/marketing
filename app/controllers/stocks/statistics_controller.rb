# This controller handles the retrieval and display of stock statistics.
# It fetches data from an external API (Synth Finance) for a given stock ticker.
class Stocks::StatisticsController < ApplicationController
  # GET /stocks/:stock_ticker/statistics
  # Retrieves and displays statistics for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock (passed in the URL)
  # @return [void]
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }
    @stock_statistics = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}", nil, headers)
    parsed_data = JSON.parse(@stock_statistics.body)["data"]
    @stock_statistics = parsed_data && parsed_data["market_data"] ? parsed_data["market_data"] : nil
  end
end
