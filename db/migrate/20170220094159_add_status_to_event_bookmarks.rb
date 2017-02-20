class AddStatusToEventBookmarks < ActiveRecord::Migration[5.0]
  def change
    add_column :event_bookmarks, :is_bookmark, :boolean, default: false
  end
end
