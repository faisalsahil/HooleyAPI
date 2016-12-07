class CreatePostVideos < ActiveRecord::Migration[5.0]
  def change
    create_table :post_videos do |t|
      t.integer :post_id
      t.string :video_url
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
