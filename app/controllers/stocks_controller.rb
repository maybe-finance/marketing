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
    @exchanges = Rails.cache.fetch("stock_exchanges_groupings", expires_in: 24.hours) do
      Stock.where(kind: "stock")
           .where.not(mic_code: nil)
           .distinct
           .pluck(:exchange, :country_code)
           .compact
           .group_by(&:first)
           .transform_values(&:first)
           .values
           .sort_by(&:first)
    end

    @industries = Rails.cache.fetch("stock_industries_groupings", expires_in: 24.hours) do
      Stock.where(kind: "stock").where.not(mic_code: nil).where.not(industry: nil).distinct.pluck(:industry, :country_code).compact.sort_by(&:first)
    end

    @sectors = Rails.cache.fetch("stock_sectors_groupings", expires_in: 24.hours) do
      Stock.where(kind: "stock").where.not(mic_code: nil).where.not(sector: nil).distinct.pluck(:sector).compact.sort
    end

    if params[:combobox].present?
      scope = Stock.order(:name).search(params[:q])
      @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
      @total_stocks = @pagy.count
      render :index, variants: [ :combobox ]
    elsif params[:q].present?
      redirect_to all_stocks_path(q: params[:q])
    end
  end

  def all
    @query = params[:q]
    scope = Stock.order(:name).where(kind: "stock").where.not(mic_code: nil)

    scope = scope.where(exchange: params[:exchange]) if params[:exchange].present?
    scope = scope.where(industry: params[:industry]) if params[:industry].present?
    scope = scope.where(sector: params[:sector]) if params[:sector].present?

    if @query.present?
      @total_stocks = scope.search(@query).count("DISTINCT stocks.id")
      scope = scope.search(@query)
    else
      @total_stocks = scope.count
    end

    @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
  end

  # GET /stocks/:ticker
  # Displays details for a specific stock
  #
  # @param ticker [String] The stock symbol (ticker) to look up
  # @return [Stock] The Stock object matching the provided ticker
  # @example
  #   GET /stocks/AAPL
  def show
    if params[:ticker].include?(":")
      symbol, mic_code = params[:ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:ticker], country_code: "US")
    end
  end

  def exchanges
    if params[:id]
      @exchange = params[:id]
      @stocks = Stock.where(exchange: @exchange).where.not(mic_code: nil).order(:name)
      @pagy, @stocks = pagy(@stocks, limit: 27, size: [ 1, 3, 3, 1 ])
      render :all
    else
      @exchanges = Stock.where(kind: "stock")
                     .where.not(mic_code: nil)
                     .distinct
                     .pluck(:exchange, :country_code)
                     .compact
                     .group_by(&:first)
                     .transform_values(&:first)
                     .values
                     .sort_by(&:first)
    end
  end

  def industries
    if params[:id]
      @industry = params[:id]
      @stocks = Stock.where(industry: @industry).where.not(mic_code: nil).order(:name)
      @pagy, @stocks = pagy(@stocks, limit: 27, size: [ 1, 3, 3, 1 ])
      render :all
    else
      @industries = Stock.where(kind: "stock").where.not(mic_code: nil).distinct.pluck(:industry).compact.sort
    end
  end

  def sectors
    if params[:id]
      @sector = sector_from_slug(params[:id])
      if @sector
        @stocks = Stock.where(sector: @sector).where.not(mic_code: nil).order(:name)
        @pagy, @stocks = pagy(@stocks, limit: 27, size: [ 1, 3, 3, 1 ])
        render :all
      else
        redirect_to stocks_path, status: :moved_permanently
      end
    else
      @sectors = Stock.where(kind: "stock").where.not(mic_code: nil).distinct.pluck(:sector).compact.sort
    end
  end

  private

  def sector_from_slug(slug)
    Stock.where(kind: "stock")
         .where.not(mic_code: nil)
         .distinct
         .pluck(:sector)
         .compact
         .find { |sector| sector_slug(sector) == slug }
  end

  def sector_slug(sector)
    sector.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/-+$/, "")
  end
end
