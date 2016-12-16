class PostAttachment < ApplicationRecord
  
  belongs_to :post
  has_many   :post_photo_users, dependent: :destroy
  accepts_nested_attributes_for :post_photo_users
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
