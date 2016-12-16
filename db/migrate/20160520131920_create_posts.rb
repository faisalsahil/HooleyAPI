class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.integer  :member_profile_id
      t.string   :post_title
      t.string   :post_type
      t.string   :location
      t.float   :latitude
      t.float   :longitude
      t.text     :post_description
      t.boolean  :is_post_public
      t.boolean  :is_deleted, default: false
      t.datetime :post_datetime
      
      t.timestamps
    end
  end
end
