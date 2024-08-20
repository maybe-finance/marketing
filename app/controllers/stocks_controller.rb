class StocksController < ApplicationController
  include Pagy::Backend

  def index
    @query = params[:q]

    @total_stocks = Stock.count

    scope = Stock.order(:name)
    scope = scope.where("symbol ILIKE :query OR name ILIKE :query", query: "%#{@query}%") if @query.present?

    # Adding pagy size configuration
    @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
  end

  def show
    @stock = Stock.find_by(symbol: params[:ticker])
  end
end
