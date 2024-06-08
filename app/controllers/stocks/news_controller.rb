class Stocks::NewsController < ApplicationController
  def show
    @stock = Stock.find_by(symbol: params[:stock_ticker])
  end
end
