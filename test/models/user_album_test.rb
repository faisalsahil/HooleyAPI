require 'test_helper'

class UserAlbumTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: user_albums
#
#  id                :integer          not null, primary key
#  name              :string
#  status            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_profile_id :integer
#  album_photo_url   :string
#  default_album     :boolean          default(FALSE)
#
