class CreateContentBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :content_blocks do |t|
      t.string :title
      t.text :content
      t.string :url_pattern, null: false
      t.string :match_type, null: false, default: 'exact'
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end
    add_index :content_blocks, :url_pattern
    add_index :content_blocks, :active
  end
end
