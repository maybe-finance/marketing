class AddSearchVectorToStocks < ActiveRecord::Migration[8.0]
  def change
    add_column :stocks, :search_vector, :virtual, type: :tsvector, as: "setweight(to_tsvector('simple', coalesce(symbol, '')), 'B') || to_tsvector('simple', coalesce(name, ''))", stored: true
    add_index :stocks, :search_vector, using: :gin
  end
end
