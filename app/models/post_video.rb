class PostVideo < ApplicationRecord
  belongs_to :post
  # validates_presence_of :video_url, presence: true
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
