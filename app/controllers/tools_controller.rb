class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.for(**tool_params)

    if @tool.slug == "home-affordability-calculator" || @tool.slug == "early-mortgage-payoff-calculator"
      @loan_interest_rate_30 = fetch_mortgage_rate("MORTGAGE30US")
      @loan_interest_rate_15 = fetch_mortgage_rate("MORTGAGE15US")
    end

    if @tool.slug == "stock-portfolio-backtest"
      @stocks = Rails.cache.fetch("all_stocks", expires_in: 24.hours) do
        Stock.select(:name, :symbol).map { |stock| { name: stock.name, value: stock.symbol } }
      end
    end

    if @tool.needs_stock_data?
      @stock_prices = StockPrice.fetch_stock_data
    end
  end

  private
    def tool_params
      params.to_unsafe_h
        .transform_values { |value| value.gsub(/[^\d.]/, "") }
        .merge(slug: params[:slug])
        .symbolize_keys
    end

    def fetch_mortgage_rate(mortgage_duration)
      cache_key = "mortgage_rate_#{mortgage_duration}"

      Rails.cache.fetch(cache_key, expires_in: 24.hours) do
        response = HTTParty.get("https://api.stlouisfed.org/fred/series/observations",
          query: {
            series_id: mortgage_duration,
            api_key: ENV["FRED_API_KEY"],
            file_type: "json",
            limit: 1,
            sort_order: "desc",
            frequency: "w"
          }
        )

        if response.success?
          JSON.parse(response.body)["observations"].first["value"]
        else
          raise "Failed to fetch mortgage rate: #{response.code} #{response.message}"
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error fetching mortgage rate: #{e.message}")
      nil
    end
end
