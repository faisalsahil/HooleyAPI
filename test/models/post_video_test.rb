require 'test_helper'

class PostVideoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_videos
#
#  id            :integer          not null, primary key
#  post_id       :integer
#  video_url     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  thumbnail_url :string
#
