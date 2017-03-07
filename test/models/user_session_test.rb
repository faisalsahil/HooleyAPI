require 'test_helper'

class UserSessionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: user_sessions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  device_type    :string
#  device_uuid    :string
#  auth_token     :string
#  session_status :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  device_token   :string
#
