# This controller handles the retrieval and display of stock statistics.
# It fetches data from an external API (Synth Finance) for a given stock ticker.
class Stocks::StatisticsController < ApplicationController
  # GET /stocks/:stock_ticker/statistics
  # Retrieves and displays statistics for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock (passed in the URL)
  # @return [void]
  def show
    if params[:stock_ticker].include?(":")
      symbol, mic_code = params[:stock_ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:stock_ticker], country_code: "US")
    end

    @stock_statistics = Rails.cache.fetch("stock_statistics/v2/#{@stock.symbol}:#{@stock.mic_code}", expires_in: 24.hours) do
      response = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}?mic_code=#{@stock.mic_code}") do |req|
        req.headers["Content-Type"] = "application/json"
        req.headers["Authorization"] = "Bearer #{ENV['SYNTH_API_KEY']}"
        req.headers["X-Source"] = "maybe_marketing"
        req.headers["X-Source-Type"] = "api"
      end
      parsed_data = JSON.parse(response.body)["data"]
      parsed_data && parsed_data["market_data"] ? parsed_data["market_data"] : nil
    end
  end
end
