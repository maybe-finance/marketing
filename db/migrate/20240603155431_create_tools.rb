class CreateTools < ActiveRecord::Migration[8.0]
  def change
    create_table :tools do |t|
      t.string :name
      t.string :slug
      t.text :intro
      t.text :description
      t.text :content

      t.timestamps
    end
  end
end
