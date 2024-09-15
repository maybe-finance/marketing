class AddIndexForStockPriceTickers < ActiveRecord::Migration[8.0]
  def change
    add_index :stock_prices, :ticker
  end
end
