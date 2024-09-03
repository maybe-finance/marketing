# This controller handles the logic for displaying and interacting with financial tools.
# It provides functionality for listing all tools and showing individual tool details.
class ToolsController < ApplicationController
  # GET /tools
  # Retrieves all tools from the database.
  #
  # @return [Array<Tool>] An array of all Tool objects.
  def index
    @tools = Tool.all
  end

  # GET /tools/:id
  # Retrieves and displays a specific tool based on its slug.
  # Also fetches additional data required for certain tools.
  #
  # @param id [String] The slug of the tool to be displayed.
  # @return [Tool] The requested Tool object.
  def show
    @tool = Tool.find_by(slug: params[:id])

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

  # Fetches the current mortgage rate for a given mortgage duration.
  #
  # @param mortgage_duration [String] The mortgage duration code (e.g., "MORTGAGE30US").
  # @return [String, nil] The current mortgage rate as a string, or nil if the fetch fails.
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
