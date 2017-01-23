class ChangeFieldsInMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :member_profiles, :occupation
    remove_column :member_profiles, :college_major
    remove_column :member_profiles, :relationship_status
    remove_column :member_profiles, :political_views
    remove_column :member_profiles, :religion
    remove_column :member_profiles, :languages
    remove_column :member_profiles, :ethnic_background

    add_column :member_profiles, :occupation_id,       :integer
    add_column :member_profiles, :college_major_id,       :integer
    add_column :member_profiles, :relationship_status_id, :integer
    add_column :member_profiles, :political_view_id,     :integer
    add_column :member_profiles, :religion_id,            :integer
    add_column :member_profiles, :language_id,           :integer
    add_column :member_profiles, :ethnic_background_id,   :integer
  end
end
