class AddPrimaryColorToInstitutions < ActiveRecord::Migration[8.0]
  def change
    add_column :institutions, :primary_color, :string
  end
end
