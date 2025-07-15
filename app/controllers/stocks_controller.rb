# StocksController handles stock-related actions in the application
# This controller provides functionality for listing stocks and displaying individual stock details
class StocksController < ApplicationController
  include Pagy::Backend
  include StocksHelper

  def index
    if params[:combobox].present?
      scope = Stock.order(:name)
      scope = scope.where(country_code: params[:country_code]) if params[:country_code].present?
      scope = scope.search(params[:q])
      @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
      @total_stocks = @pagy.count
      render :index, variants: [ :combobox ]
    else
      head :not_found
    end
  end
end
