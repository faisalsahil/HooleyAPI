class AddDefaultAlbumColumnToUserAlbums < ActiveRecord::Migration[5.0]
  def change
    add_column :user_albums, :default_album, :boolean, default: false
  end
end
