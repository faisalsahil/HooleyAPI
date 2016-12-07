class ChangingColumnsInAlbumImages < ActiveRecord::Migration[5.0]
  def change
    add_column :album_images, :attachment_url,     :string
    add_column :album_images, :thumbnail_url,      :string
    add_column :album_images, :post_attachment_id, :integer
  end
end
