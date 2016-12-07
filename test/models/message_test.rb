require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  sender_id   :integer
#  reciever_id :integer
#  content     :text
#  subject     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
