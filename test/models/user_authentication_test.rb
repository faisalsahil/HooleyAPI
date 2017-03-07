require 'test_helper'

class UserAuthenticationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
