class CreatePostComments < ActiveRecord::Migration[5.0]
  def change
    create_table :post_comments do |t|
      t.integer :post_id
      t.integer :member_profile_id
      t.text :post_comment
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
