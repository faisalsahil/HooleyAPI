class AddAboutFieldToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :about, :text
  end
end
