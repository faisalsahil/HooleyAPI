class ChangeColumnTypeIntoPosts < ActiveRecord::Migration[5.0]
  def change
    remove_column :posts, :latitude
    remove_column :posts, :longitude

    add_column :posts, :latitude, :float
    add_column :posts, :longitude, :float

  end
end
