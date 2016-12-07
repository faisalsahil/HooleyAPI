require 'test_helper'

class PostMemberTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_members
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
