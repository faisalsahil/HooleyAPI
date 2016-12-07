class CreatePostLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :post_likes do |t|
      t.integer :post_id
      t.integer :member_profile_id
      t.boolean :is_deleted, default: false
      t.boolean :like_status, default: false
      t.timestamps
    end
  end
end
