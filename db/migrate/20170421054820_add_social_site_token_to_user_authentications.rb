class AddSocialSiteTokenToUserAuthentications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_authentications, :social_site_token, :string
  end
end
