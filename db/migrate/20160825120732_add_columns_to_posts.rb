class AddColumnsToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :post_type, :string
    add_column :posts, :x_coordinate, :float
    add_column :posts, :y_coordinate, :float
  end
end
