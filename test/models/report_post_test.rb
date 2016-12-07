require 'test_helper'

class ReportPostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: report_posts
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
