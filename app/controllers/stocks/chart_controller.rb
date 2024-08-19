class Stocks::ChartController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['SYNTH_API_KEY']}"
    }
    @stock_chart = Faraday.get("https://api.synthfinance.com/tickers/#{@stock.symbol}", nil, headers)
    @stock_chart = JSON.parse(@stock_chart.body)["data"]
  end
end
