class AddAlbumPhotoUrlColumnToUserAlbums < ActiveRecord::Migration[5.0]
  def change
    add_column :user_albums, :album_photo_url, :string
  end
end
