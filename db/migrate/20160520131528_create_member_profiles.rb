class CreateMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :member_profiles do |t|
      t.string  :phone
      t.string  :photo, default: 'http://bit.ly/25CCXzq'
      t.string  :gender
      t.string  :dob
      t.string  :account_type
      t.string  :current_city,        :string
      t.string  :home_town,           :string
      t.string  :occupation,          :string
      t.string  :employer,            :string
      t.string  :college,             :string
      t.string  :college_major,       :string
      t.string  :high_school,         :string
      t.string  :organization,        :string
      t.string  :hobbies,             :string
      t.string  :relationship_status, :string
      t.string  :political_views,     :string
      t.string  :religion,            :string
      t.string  :languages,           :string
      t.string  :ethnic_background,   :string
      t.string  :contact_email,       :string
      t.string  :contact_phone,       :string
      t.string  :contact_website,     :string
      t.string  :contact_address,     :string
      t.integer :city_id
      t.integer :country_id
      t.integer :default_group_id
      t.boolean :is_age_visible,      defaut: false
      t.boolean :is_profile_public
      
      t.timestamps
    end
  end
end
