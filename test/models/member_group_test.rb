require 'test_helper'

class MemberGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: member_groups
#
#  id                :integer          not null, primary key
#  member_profile_id :integer
#  group_name        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_deleted        :boolean          default(FALSE)
#
