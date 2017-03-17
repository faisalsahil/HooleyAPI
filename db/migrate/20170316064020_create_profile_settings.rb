class CreateProfileSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_settings do |t|
      t.boolean :is_near_me_event_alert,     default: true
      t.boolean :is_hooly_invite_alert,      default: true
      t.boolean :is_my_upcoming_event_alert, default: true
      t.boolean :is_direct_message_alert,    default: true
      t.integer :is_contact_info_shown,      default: 2
      t.integer :is_social_info_shown,       default: 2
      t.integer :is_direct_message_allow,    default: 2
      t.integer :is_private_media_share,     default: 2
      t.integer :is_public_media_share,      default: 2
      t.integer :near_event_search,          default: 5
      t.timestamps
    end
  end
end
