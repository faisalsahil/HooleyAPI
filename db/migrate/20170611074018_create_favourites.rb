class CreateFavourites < ActiveRecord::Migration[5.0]
  def change
    create_table :favourites do |t|
      t.integer :member_profile_id
      t.integer :event_id
      t.timestamps
    end
  end
end
