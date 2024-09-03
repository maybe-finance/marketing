# This controller handles the retrieval and processing of similar stocks for a given stock ticker.
# It interacts with an external API (Synth Finance) to fetch related stock data and formats it for display.
class Stocks::SimilarStocksController < ApplicationController
  # GET /stocks/:stock_ticker/similar
  # Fetches and processes similar stocks data for the specified stock ticker.
  #
  # @param stock_ticker [String] The ticker symbol of the stock to find similar stocks for.
  # @return [void]
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }

    response = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}/related", nil, headers)
    data = JSON.parse(response.body)["data"]

    @similar_stocks_data = []
    data["related_tickers"].each do |related_stock|
      break if @similar_stocks_data.size == 6

      market_data = related_stock["market_data"]
      next if market_data.nil? || market_data.empty?
      next if market_data["open_today"].nil? || market_data["price_change"].nil? || market_data["percent_change"].nil?

      current_price = market_data["open_today"].to_f
      price_change = market_data["price_change"]
      percent_change = market_data["percent_change"]

      @similar_stocks_data << {
        name: related_stock["name"],
        symbol: related_stock["ticker"],
        current_price: current_price,
        price_change: price_change,
        percent_change: percent_change
      }
    end
  end
end
