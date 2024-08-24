class Stocks::InfoController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}",
      "X-Source" => "maybe_marketing",
      "X-Source-Type" => "api"
    }
    @stock_info = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}", nil, headers)
    @stock_info = JSON.parse(@stock_info.body)["data"]
  end
end
