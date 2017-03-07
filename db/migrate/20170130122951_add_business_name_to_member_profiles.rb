class AddBusinessNameToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :business_name, :string
  end
end
