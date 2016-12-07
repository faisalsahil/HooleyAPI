class CreateCountries < ActiveRecord::Migration[5.0]
  def change
    create_table :countries do |t|
      t.string :country_name
      t.string :iso
      t.string :iso2
      t.string :iso3
      t.integer :currency_id
      t.timestamps
    end
  end
end