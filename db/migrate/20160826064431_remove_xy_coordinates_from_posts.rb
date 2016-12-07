class RemoveXyCoordinatesFromPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :x_coordinate
    remove_column :posts, :y_coordinate
  end
end
