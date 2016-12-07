require 'test_helper'

class PostPhotoUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_photo_users
#
#  id                 :integer          not null, primary key
#  x_coordinate       :float
#  y_coordinate       :float
#  member_profile_id  :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  post_attachment_id :integer
#
