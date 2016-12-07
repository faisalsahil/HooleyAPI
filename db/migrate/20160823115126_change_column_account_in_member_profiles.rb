class ChangeColumnAccountInMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    remove_column :member_profiles, :account_id
    add_column :member_profiles, :account_type, :string
  end
end
