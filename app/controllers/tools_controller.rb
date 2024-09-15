class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.for(**tool_params)

    # if @tool.slug == "stock-portfolio-backtest"
    #   @stocks = Rails.cache.fetch("all_stocks", expires_in: 24.hours) do
    #     Stock.select(:name, :symbol).map { |stock| { name: stock.name, value: stock.symbol } }
    #   end
    # end
  end

  private
    def tool_params
      params.to_unsafe_h
        .transform_values { |value| value.gsub(/[^\d.]/, "") } # Remove non-numeric characters added by autonumeric
        .merge(slug: params[:slug])
        .symbolize_keys
    end
end
