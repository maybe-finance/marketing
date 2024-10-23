# StocksController handles stock-related actions in the application
# This controller provides functionality for listing stocks and displaying individual stock details
class StocksController < ApplicationController
  include Pagy::Backend

  # GET /stocks
  # Lists stocks with optional filtering and pagination
  #
  # @param q [String] Optional query parameter for filtering stocks by symbol or name
  # @return [Array<Stock>] Paginated array of Stock objects
  # @example
  #   GET /stocks
  #   GET /stocks?q=AAPL
  def index
    @query = params[:q]
    scope = Stock.order(:name).search(@query)
    @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
    @total_stocks = @pagy.count

    render :index, variants: [ :combobox ] if params[:combobox].present?
  end

  # GET /stocks/:ticker
  # Displays details for a specific stock
  #
  # @param ticker [String] The stock symbol (ticker) to look up
  # @return [Stock] The Stock object matching the provided ticker
  # @example
  #   GET /stocks/AAPL
  def show
    @stock = Stock.find_by(symbol: params[:ticker])
  end
end
