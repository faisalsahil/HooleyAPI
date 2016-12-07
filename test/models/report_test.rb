require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  comment           :text
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reportable_id     :integer
#  reportable_type   :string
#
