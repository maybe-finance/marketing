class Stocks::StatisticsController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])
    
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }
    @stock_statistics = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}", nil, headers)
    @stock_statistics = JSON.parse(@stock_statistics.body)["data"]["market_data"]
  end
end
