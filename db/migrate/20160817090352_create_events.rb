class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.string   :name
      t.integer  :country_id
      t.integer  :state_id
      t.integer  :city_id
      t.text     :organization
      t.text     :location
      t.text     :description
      t.integer  :cost
      t.integer  :currency_id
      t.text     :camp_website
      t.datetime :start_date
      t.datetime :end_date
      t.string   :upload
      t.integer  :member_profile_id

      t.timestamps
    end
  end
end
