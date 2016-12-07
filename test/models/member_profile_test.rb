require 'test_helper'

class MemberProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: member_profiles
#
#  id                :integer          not null, primary key
#  photo             :string           default("http://bit.ly/25CCXzq")
#  country_id        :integer
#  school_name       :string
#  is_profile_public :boolean
#  default_group_id  :integer
#  gender            :string
#  dob               :string
#  promotion_updates :boolean          default(FALSE)
#  state_id          :integer
#  city_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sport_id          :integer
#  sport_position_id :integer
#  sport_level_id    :integer
#  account_type      :string
#
