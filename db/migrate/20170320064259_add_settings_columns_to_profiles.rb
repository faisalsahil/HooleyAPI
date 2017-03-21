class AddSettingsColumnsToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :is_near_me_event_alert,     :boolean,  default: true
    add_column :member_profiles, :is_hooly_invite_alert,      :boolean,  default: true
    add_column :member_profiles, :is_my_upcoming_event_alert, :boolean,  default: true
    add_column :member_profiles, :is_direct_message_alert,    :boolean,  default: true
    add_column :member_profiles, :is_contact_info_shown,      :string,  default: 'public'
    add_column :member_profiles, :is_social_info_shown,       :string,  default: 'public'
    add_column :member_profiles, :is_direct_message_allow,    :string,  default: 'public'
    add_column :member_profiles, :is_private_media_share,     :string,  default: 'public'
    add_column :member_profiles, :is_public_media_share,      :string,  default: 'public'
    add_column :member_profiles, :near_event_search,          :integer, default:  5
  end
end
