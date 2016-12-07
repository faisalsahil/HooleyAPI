require 'test_helper'

class ReportCommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: report_comments
#
#  id                :integer          not null, primary key
#  post_comment_id   :integer
#  member_profile_id :integer
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
