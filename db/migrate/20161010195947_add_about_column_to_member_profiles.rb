class AddAboutColumnToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :about, :string
  end
end
