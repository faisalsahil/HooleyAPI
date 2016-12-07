class CreateEventSports < ActiveRecord::Migration[5.0]
  def change
    create_table :event_sports do |t|
      t.integer :event_id
      t.integer :sport_id
      t.integer :sport_position_id

      t.timestamps
    end
  end
end
