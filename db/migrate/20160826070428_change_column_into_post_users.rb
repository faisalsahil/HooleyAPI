class ChangeColumnIntoPostUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :post_users, :user_id
    add_column    :post_users, :member_profile_id, :integer
  end
end
