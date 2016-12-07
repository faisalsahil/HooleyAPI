class AddCountryIdToCurrencies < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :country_id, :integer
  end
end
