class CreateUserSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sessions do |t|
      t.integer :user_id
      t.string :device_type
      t.string :device_uuid
      t.string :auth_token
      t.string :session_status
      t.string :device_token

      t.timestamps
    end
  end
end
