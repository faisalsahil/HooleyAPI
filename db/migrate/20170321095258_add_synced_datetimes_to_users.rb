class AddSyncedDatetimesToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :following_sync_datetime, :datetime
    add_column :users, :nearme_sync_datetime,    :datetime
    add_column :users, :trending_sync_datetime,  :datetime
    
    remove_column :users, :synced_datetime
  end
end
