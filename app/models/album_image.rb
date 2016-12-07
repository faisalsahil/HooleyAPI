class AlbumImage < ApplicationRecord
  belongs_to :user_album
  belongs_to :post
  belongs_to :post_attachment
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
