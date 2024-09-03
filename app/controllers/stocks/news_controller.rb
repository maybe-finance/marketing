# This controller handles requests for stock news.
# It fetches news articles related to a specific stock from the Synth Finance API.
class Stocks::NewsController < ApplicationController
  # GET /stocks/:stock_ticker/news
  # Retrieves and displays news articles for a specific stock.
  #
  # @param stock_ticker [String] The ticker symbol of the stock (passed in the URL)
  # @return [Array] An array of news articles related to the specified stock
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }
    
    # Fetch news articles from the Synth Finance API
    @stock_news = Faraday.get("https://api.synthfinance.com/news/#{@stock.symbol}", nil, headers)
    
    # Parse the response and limit to the first 4 articles
    @stock_news = JSON.parse(@stock_news.body)["data"].first(4)
  end
end
