require 'test_helper'

class PostLikeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_likes
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  is_deleted        :boolean          default(FALSE)
#  like_status       :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
