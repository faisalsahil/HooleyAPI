class CreateEventMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :event_members do |t|
      t.integer :event_id
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
