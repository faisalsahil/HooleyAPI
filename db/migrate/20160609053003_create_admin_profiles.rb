class CreateAdminProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :admin_profiles do |t|
      t.text :about
      t.string :phone
      t.integer :country_id
      t.string :state
      t.string :photo

      t.timestamps
    end
  end
end
