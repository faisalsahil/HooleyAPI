class AddColumnToUserAlbums < ActiveRecord::Migration[5.0]
  def change
    remove_column :user_albums, :user_id
    add_column :user_albums, :member_profile_id, :integer
  end
end
