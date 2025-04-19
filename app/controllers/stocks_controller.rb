# StocksController handles stock-related actions in the application
# This controller provides functionality for listing stocks and displaying individual stock details
class StocksController < ApplicationController
  include Pagy::Backend
  include StocksHelper

  # GET /stocks
  # Lists stocks with optional filtering and pagination
  #
  # @param q [String] Optional query parameter for filtering stocks by symbol or name
  # @return [Array<Stock>] Paginated array of Stock objects
  # @example
  #   GET /stocks
  #   GET /stocks?q=AAPL

  def index
    @exchanges = Rails.cache.fetch("stock_exchanges_groupings/v3", expires_in: 24.hours) do
      Stock.where(kind: "stock")
           .where.not(mic_code: nil)
           .distinct
           .pluck(:exchange, :country_code)
           .compact
           .group_by(&:first)
           .transform_values(&:first)
           .values
           .sort_by { |exchange, _| exchange.to_s }
    end

    @featured_stocks = FEATURED_STOCKS.sample(12).map { |stock| Stock.find_by(symbol: stock) }

    @industries = Rails.cache.fetch("stock_industries_groupings/v3", expires_in: 24.hours) do
      Stock.where(kind: "stock").where.not(mic_code: nil).where.not(industry: nil).distinct.pluck(:industry, :country_code).compact.sort_by(&:first)
    end

    @sectors = Rails.cache.fetch("stock_sectors_groupings/v3", expires_in: 24.hours) do
      Stock.where(kind: "stock").where.not(mic_code: nil).where.not(sector: nil).distinct.pluck(:sector).compact.sort
    end

    if params[:combobox].present?
      scope = Stock.order(:name)
      scope = scope.where(country_code: params[:country_code]) if params[:country_code].present?
      scope = scope.search(params[:q])
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
      if params[:ticker].end_with?(":")
        redirect_to stock_path(params[:ticker].chomp(":")) and return
      end
      symbol, mic_code = params[:ticker].split(":")
      @stock = Stock.find_by(symbol:, mic_code:)
    else
      @stock = Stock.find_by(symbol: params[:ticker])
    end

    if cached = Rails.cache.read("stock_page/#{@stock.symbol}:#{@stock.mic_code}")
      @cached_content = cached.html_safe
    end

    redirect_to stocks_path unless @stock && @stock.country_code.present?
  end

  def exchanges
    if params[:id]
      @exchange = params[:id]
      if @exchange.present?
        scope = Rails.cache.fetch("exchange_stocks/#{@exchange}/v3", expires_in: 12.hours) do
          Stock.where(exchange: @exchange).where.not(mic_code: nil).order(:name)
        end
        return redirect_to stocks_path if scope.empty?

        @pagy, @stocks = pagy(scope, limit: 27, size: [ 1, 3, 3, 1 ])
        @total_stocks = @pagy.count
        render :all
      else
        redirect_to stocks_path and return
      end
    else
      @exchanges = Rails.cache.fetch("exchanges_list/v3", expires_in: 24.hours) do
        Stock.where(kind: "stock")
             .where.not(mic_code: nil)
             .distinct
             .pluck(:exchange, :country_code)
             .compact
             .group_by(&:first)
             .transform_values(&:first)
             .values
      end

      redirect_to stocks_path and return if @exchanges.empty?
    end
  end

  def industries
    if params[:id]
      @industry = params[:id]
      if @industry.present?
        @stocks = Stock.where(industry: @industry).where.not(mic_code: nil).order(:name)
        @pagy, @stocks = pagy(@stocks, limit: 27, size: [ 1, 3, 3, 1 ])
        @total_stocks = @pagy.count
        render :all
      else
        redirect_to stocks_path and return
      end
    else
      @industries = Stock.where(kind: "stock")
                        .where.not(mic_code: nil)
                        .distinct
                        .pluck(:industry)
                        .compact
                        .sort

      redirect_to stocks_path and return if @industries.empty?
    end
  end

  def sectors
    if params[:id]
      @sector = sector_from_slug(params[:id])
      if @sector
        @stocks = Stock.where(sector: @sector).where.not(mic_code: nil).order(:name)
        @pagy, @stocks = pagy(@stocks, limit: 27, size: [ 1, 3, 3, 1 ])
        @total_stocks = @pagy.count
        render :all
      else
        redirect_to stocks_path, status: :moved_permanently
      end
    else
      @sectors = Stock.where(kind: "stock").where.not(mic_code: nil).distinct.pluck(:sector).compact.sort
      return if @sectors.present?
      redirect_to stocks_path
    end
  end

  def cache_page
    Rails.cache.write(
      "stock_page/#{params[:key]}",
      params[:content],
      expires_in: 12.hours
    )
    head :ok
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
