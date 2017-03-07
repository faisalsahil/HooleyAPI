require 'test_helper'

class PostAttachmentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: post_attachments
#
#  id              :integer          not null, primary key
#  post_id         :integer
#  attachment_url  :string
#  thumbnail_url   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachment_type :string
#
