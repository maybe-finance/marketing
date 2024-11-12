class AddStockDetailsToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :exchange, :string
    add_column :stocks, :mic_code, :string
    add_column :stocks, :country_code, :string
    add_column :stocks, :kind, :string
    add_column :stocks, :industry, :string
    add_column :stocks, :sector, :string

    add_index :stocks, :exchange
    add_index :stocks, :mic_code
    add_index :stocks, :country_code
    add_index :stocks, :kind
    add_index :stocks, [ :symbol, :mic_code ], unique: true
  end
end
