class UserAuthentication < ApplicationRecord
  belongs_to :user

  def self.find_from_social_data hash
    find_by_social_site_and_social_site_id(hash[:social_site], hash[:social_site_id])
  end

  def self.create_from_social_data(hash, user)
    auth = UserAuthentication.create(
        user_id:           user.id,
        social_site:       hash[:social_site],
        social_site_id:    hash[:social_site_id],
        social_site_token: hash[:social_site_token],
        username:       hash[:username] || nil,
        email:          hash[:email] || nil
    )
  end
end

# == Schema Information
#
# Table name: user_authentications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  social_site_id    :string
#  social_site       :string
#  profile_image_url :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
