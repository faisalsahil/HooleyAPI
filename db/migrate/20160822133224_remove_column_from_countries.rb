class RemoveColumnFromCountries < ActiveRecord::Migration[5.0]
  def change
    remove_column :countries, :currency_id
  end
end
