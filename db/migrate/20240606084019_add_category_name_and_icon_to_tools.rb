class AddCategoryNameAndIconToTools < ActiveRecord::Migration[8.0]
  def change
    add_column :tools, :category_slug, :string
    add_column :tools, :icon, :string
  end
end
