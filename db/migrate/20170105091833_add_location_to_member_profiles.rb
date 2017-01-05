class AddLocationToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :latitude, :float
    add_column :member_profiles, :longitude, :float
    add_column :member_profiles, :location, :string
  end
end
