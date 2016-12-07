class CreateMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :member_profiles do |t|
      t.text    :about
      t.string  :phone
      t.string  :photo, default: 'http://bit.ly/25CCXzq'
      t.integer :country_id
      t.string  :school_name
      t.boolean :is_profile_public
      t.integer :default_group_id
      t.string :gender
      t.string  :dob
      t.string  :account_type
      t.boolean :promotion_updates, default: false
      t.integer :state_id
      t.integer :city_id

      t.timestamps
    end
  end
end
