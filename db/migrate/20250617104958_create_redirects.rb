class CreateRedirects < ActiveRecord::Migration[8.0]
  def change
    create_table :redirects do |t|
      t.string :source_path, null: false
      t.string :destination_path, null: false
      t.string :redirect_type, null: false, default: "permanent"
      t.string :pattern_type, null: false, default: "exact"
      t.boolean :active, default: true
      t.integer :priority, null: false, default: 1

      t.timestamps
    end

    add_index :redirects, :source_path, unique: true
    add_index :redirects, [ :active, :priority ]
  end
end
