class CreateStockPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_prices do |t|
      t.string :ticker
      t.float :price
      t.integer :year

      t.timestamps
    end
  end
end
