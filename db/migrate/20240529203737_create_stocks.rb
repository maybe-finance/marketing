class CreateStocks < ActiveRecord::Migration[8.0]
  def change
    create_table :stocks do |t|
      t.string :symbol
      t.string :name
      t.string :legal_name
      t.jsonb :links, default: {}
      t.text :description

      t.timestamps
    end
  end
end
