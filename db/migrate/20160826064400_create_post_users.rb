class CreatePostUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :post_users do |t|
      t.float :x_coordinate
      t.float :y_coordinate
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end
  end
end
