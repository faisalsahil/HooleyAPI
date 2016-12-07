class CreateAlbumImages < ActiveRecord::Migration[5.0]
  def change
    create_table :album_images do |t|
      t.integer :user_album_id
      t.integer :post_id

      t.timestamps
    end
  end
end
