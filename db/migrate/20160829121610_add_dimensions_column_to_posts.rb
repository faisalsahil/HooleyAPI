class AddDimensionsColumnToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :location, :string
    add_column :posts, :latitude, :string
    add_column :posts, :longitude, :string
  end
end
