require 'test_helper'

class AlbumImageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: album_images
#
#  id                 :integer          not null, primary key
#  user_album_id      :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  attachment_url     :string
#  thumbnail_url      :string
#  post_attachment_id :integer
#  post_id            :integer
#
