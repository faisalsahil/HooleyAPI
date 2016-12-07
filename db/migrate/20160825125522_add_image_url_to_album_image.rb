class AddImageUrlToAlbumImage < ActiveRecord::Migration[5.0]
  def change
    add_column :album_images, :image_url, :string
    remove_column :album_images, :post_id
  end
end
