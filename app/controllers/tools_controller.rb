class ToolsController < ApplicationController
  def index
    @tools = Tool.all
  end

  def show
    @tool = Tool.find_by(slug: params[:id])

    if @tool.needs_stock_data?
      @stock_prices = StockPrice.fetch_stock_data
    end
  end
end
