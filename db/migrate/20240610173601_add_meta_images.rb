class AddMetaImages < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :meta_image_url, :string
    add_column :stocks, :meta_image_url, :string
    add_column :terms, :meta_image_url, :string
    add_column :tools, :meta_image_url, :string
  end
end
