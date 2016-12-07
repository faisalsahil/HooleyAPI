class AddAdminProfileIdToBanner < ActiveRecord::Migration[5.0]
  def change
    add_column :banners, :admin_profile_id, :integer
  end
end
