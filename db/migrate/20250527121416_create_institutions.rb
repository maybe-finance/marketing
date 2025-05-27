class CreateInstitutions < ActiveRecord::Migration[8.0]
  def change
    create_table :institutions, id: false do |t|
      t.string :institution_id, primary_key: true, null: false
      t.string :name, null: false
      t.string :country_codes, array: true, default: []
      t.string :products, array: true, default: []
      t.jsonb :status, default: {}
      t.string :logo_url
      t.string :website

      t.timestamps
    end

    # Add indexes for efficient searching
    add_index :institutions, :name
    add_index :institutions, :country_codes, using: 'gin'
    add_index :institutions, :products, using: 'gin'
    add_index :institutions, :status, using: 'gin'
  end
end
