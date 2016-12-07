class CreatePostPhotoUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :post_photo_users do |t|
      t.float :x_coordinate
      t.float :y_coordinate
      t.integer :post_id
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
