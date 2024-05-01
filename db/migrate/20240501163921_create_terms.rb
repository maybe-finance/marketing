class CreateTerms < ActiveRecord::Migration[7.2]
  def change
    create_table :terms do |t|
      t.string :name
      t.string :title
      t.text :content
      t.string :slug

      t.timestamps
    end
  end
end
