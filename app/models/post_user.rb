class PostUser < ApplicationRecord
  belongs_to :post
  belongs_to :member_profile
end

# == Schema Information
#
# Table name: post_users
#
#  id                :integer          not null, primary key
#  x_coordinate      :float
#  y_coordinate      :float
#  post_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_profile_id :integer
#
