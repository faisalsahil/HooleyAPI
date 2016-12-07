class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :profile_id, :integer
    add_column :users, :profile_type, :string
    add_column :users, :full_name, :string
    add_column :users, :username, :string
    add_column :users, :user_status, :string
    add_column :users, :authentication_token, :string
    add_index  :users, :authentication_token
    add_column :users, :gender, :string
    add_column :users, :banner_image_1, :string
    add_column :users, :banner_image_2, :string
    add_column :users, :banner_image_3, :string
    add_column :users, :promotion, :string
    add_column :users, :is_deleted, :boolean, default: false
    add_column :users, :last_subscription_time, :datetime
    add_column :users, :synced_datetime, :datetime
    add_column :users, :first_name, :string
    add_column :users, :last_name,  :string
    add_column :users, :retype_email, :string
  end
end
