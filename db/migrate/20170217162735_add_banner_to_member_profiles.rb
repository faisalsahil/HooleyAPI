class AddBannerToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :banner_image, :string
  end
end
