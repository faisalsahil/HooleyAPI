class Setting < ApplicationRecord
end

# == Schema Information
#
# Table name: settings
#
#  id                                :integer          not null, primary key
#  site_name                         :string
#  email_from                        :string
#  pagination_limit                  :string
#  admin_pagination_limit            :string
#  default_video_url                 :string
#  video_center_thumb_url            :string
#  video_center_video_url            :string
#  facebook_link                     :string
#  twitter_link                      :string
#  google_plus_link                  :string
#  premier_account_subscriptiton_amo :integer
#  authorize_api_login_id            :string
#  authorize_transaction_key         :string
#  top_alert_text                    :text
#  default_banner_1                  :string
#  default_banner_2                  :string
#  default_banner_3                  :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#
