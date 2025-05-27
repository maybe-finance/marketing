class AddOauthToInstitutions < ActiveRecord::Migration[8.0]
  def change
    add_column :institutions, :oauth, :boolean
  end
end
