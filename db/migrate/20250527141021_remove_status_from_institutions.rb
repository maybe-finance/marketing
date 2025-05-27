class RemoveStatusFromInstitutions < ActiveRecord::Migration[7.1]
  def change
    remove_column :institutions, :status, :jsonb
  end
end
