class ChangeForeignKeyIntoPostPhotoUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :post_photo_users, :post_id
    add_column :post_photo_users, :post_attachment_id, :integer
  end
end
