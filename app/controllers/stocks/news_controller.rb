class Stocks::NewsController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}"
    }
    @stock_news = Faraday.get("https://api.synthfinance.com/news/#{@stock.symbol}", nil, headers)
    @stock_news = JSON.parse(@stock_news.body)["data"].first(4)
  end
end
