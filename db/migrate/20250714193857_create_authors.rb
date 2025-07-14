class CreateAuthors < ActiveRecord::Migration[8.0]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :bio
      t.string :avatar_url
      t.string :position
      t.string :email
      t.jsonb :social_links, default: {}

      t.timestamps
    end
    add_index :authors, :slug, unique: true
    add_index :authors, :name
  end
end
