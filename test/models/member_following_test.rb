require 'test_helper'

class MemberFollowingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: member_followings
#
#  id                   :integer          not null, primary key
#  member_profile_id    :integer
#  following_profile_id :integer
#  following_status     :string           default("pending")
#  is_deleted           :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
