class CreateAuthorships < ActiveRecord::Migration[8.0]
  def change
    create_table :authorships do |t|
      t.references :author, null: false, foreign_key: true
      t.references :authorable, polymorphic: true, null: false
      t.string :role, default: "primary"
      t.integer :position, default: 0

      t.timestamps
    end

    add_index :authorships, [ :authorable_type, :authorable_id ]
    add_index :authorships, [ :author_id, :authorable_type ]
    add_index :authorships, :position
  end
end
