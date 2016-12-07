class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer  :member_profile_id
      t.string   :post_title
      t.datetime :post_datetime
      t.text     :post_description
      t.boolean  :is_post_public
      t.boolean  :is_deleted, default: false


      t.timestamps
    end
  end
end
