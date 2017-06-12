class AddPostIdToFavourites < ActiveRecord::Migration[5.0]
  def change
    remove_column :favourites, :event_id
    add_column    :favourites, :post_id, :integer
  end
end
