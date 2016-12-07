require 'test_helper'

class PostCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_comments
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  post_comment      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_deleted        :boolean          default(FALSE)
#
