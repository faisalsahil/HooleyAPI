class AddPostIdToAlbumImages < ActiveRecord::Migration[5.0]
  def change
    add_column :album_images, :post_id, :integer
  end
end
