class CreateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :settings do |t|
      t.string :site_name
      t.string :email_from
      t.string :pagination_limit
      t.string :admin_pagination_limit
      t.string :default_video_url
      t.string :video_center_thumb_url
      t.string :video_center_video_url
      t.string :facebook_link
      t.string :twitter_link
      t.string :google_plus_link
      t.integer :premier_account_subscriptiton_amo
      t.string :authorize_api_login_id
      t.string :authorize_transaction_key
      t.text :top_alert_text
      t.string :default_banner_1
      t.string :default_banner_2
      t.string :default_banner_3

      t.timestamps
    end
  end
end
