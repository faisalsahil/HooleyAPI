class CreateUserAlbums < ActiveRecord::Migration[5.0]
  def change
    create_table :user_albums do |t|
      t.integer  :member_profile_id
      t.string   :name
      t.string   :album_photo_url
      t.boolean  :status
      t.boolean  :default_album, default: false

      t.timestamps
    end
  end
end
