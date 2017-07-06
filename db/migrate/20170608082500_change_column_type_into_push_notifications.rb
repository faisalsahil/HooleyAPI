class ChangeColumnTypeIntoPushNotifications < ActiveRecord::Migration[5.0]
  def change
    # remove_column :push_notifications, :user_id
    # add_column    :push_notifications, :user_id, :integer
  end
end
