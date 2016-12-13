class CreateProfileInterests < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_interests do |t|
      t.string  :name
      t.string  :interest_type
      t.string  :photo_url
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
