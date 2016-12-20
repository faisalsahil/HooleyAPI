class RemoveColumnsFromEvents < ActiveRecord::Migration[5.0]
  def change
    remove_column :events, :name
    remove_column :events, :country_id
    remove_column :events, :state_id
    remove_column :events, :city_id
    remove_column :events, :organization
    remove_column :events, :description
    remove_column :events, :cost
    remove_column :events, :currency_id
    remove_column :events, :camp_website
    remove_column :events, :upload
  end
end
