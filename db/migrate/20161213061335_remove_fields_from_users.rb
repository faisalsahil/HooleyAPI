class RemoveFieldsFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :user_status
    remove_column :users, :gender
    remove_column :users, :banner_image_1
    remove_column :users, :banner_image_2
    remove_column :users, :banner_image_3
    remove_column :users, :promotion
  end
end
