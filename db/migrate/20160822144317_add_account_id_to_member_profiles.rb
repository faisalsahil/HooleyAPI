class AddAccountIdToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :member_profiles, :account_type
    add_column :member_profiles, :account_id, :integer
  end
end
