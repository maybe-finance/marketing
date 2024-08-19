class CreateStockPrices < ActiveRecord::Migration[8.0]
  def change
    create_table :stock_prices do |t|
      t.string :ticker
      t.float :price
      t.integer :month
      t.integer :year
      t.string :date

      t.timestamps
    end
  end
end
