class AddColumnsToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :is_age_visible,      :boolean, defaut: false
    add_column :member_profiles, :current_city,        :string
    add_column :member_profiles, :home_town,           :string
    add_column :member_profiles, :occupation,          :string
    add_column :member_profiles, :employer,            :string
    add_column :member_profiles, :college,             :string
    add_column :member_profiles, :college_major,       :string
    add_column :member_profiles, :high_school,         :string
    add_column :member_profiles, :organization,        :string
    add_column :member_profiles, :hobbies,             :string
    add_column :member_profiles, :relationship_status, :string
    add_column :member_profiles, :political_views,     :string
    add_column :member_profiles, :religion,            :string
    add_column :member_profiles, :languages,           :string
    add_column :member_profiles, :ethnic_background,   :string
    add_column :member_profiles, :contact_email,       :string
    add_column :member_profiles, :contact_phone,       :string
    add_column :member_profiles, :contact_website,     :string
    add_column :member_profiles, :contact_address,     :string
  end
end
