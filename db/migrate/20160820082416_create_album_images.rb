class CreateAlbumImages < ActiveRecord::Migration[5.0]
  def change
    create_table :album_images do |t|
      t.integer :user_album_id
      t.integer :post_id
      t.integer :post_attachment_id
      t.string  :attachment_url
      t.string  :thumbnail_url
      
      t.timestamps
    end
  end
end
