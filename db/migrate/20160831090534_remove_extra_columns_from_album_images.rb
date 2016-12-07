class RemoveExtraColumnsFromAlbumImages < ActiveRecord::Migration[5.0]
  def change
    remove_column :album_images, :post_id
    remove_column :album_images, :image_url
  end
end
