class CreateEventHashTags < ActiveRecord::Migration[5.0]
  def change
    create_table :event_hash_tags do |t|
      t.integer :event_id
      t.integer :hashtag_id

      t.timestamps
    end
  end
end
