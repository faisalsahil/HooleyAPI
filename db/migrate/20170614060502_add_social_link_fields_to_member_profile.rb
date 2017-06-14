class AddSocialLinkFieldsToMemberProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :linkden_link,  :string
    add_column :member_profiles, :facebook_link, :string
    add_column :member_profiles, :flikker_link,  :string
    add_column :member_profiles, :twitter_link,  :string
    add_column :member_profiles, :instagram_link,:string
  end
end
