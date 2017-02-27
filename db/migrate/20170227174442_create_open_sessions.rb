class CreateOpenSessions < ActiveRecord::Migration[5.0]
  def change
    create_table :open_sessions do |t|
      t.integer :user_id
      t.string :session_id
      t.integer :media_id
      t.string :media_type

      t.timestamps
    end
  end
end
