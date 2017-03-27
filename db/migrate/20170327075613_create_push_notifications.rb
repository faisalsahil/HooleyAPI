class CreatePushNotifications < ActiveRecord::Migration[5.0]
  def change
    create_table :push_notifications do |t|
      t.string :alert
      t.integer :badge
      t.string :screen
      t.json :screen_data
      t.uuid :user_id

      t.timestamps
    end
  end
end
