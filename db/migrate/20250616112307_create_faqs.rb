class CreateFaqs < ActiveRecord::Migration[8.0]
  def change
    create_table :faqs do |t|
      t.string :question
      t.text :answer
      t.string :slug
      t.string :category
      t.string :meta_image_url

      t.timestamps
    end

    add_index :faqs, :slug, unique: true
    add_index :faqs, :category
  end
end
