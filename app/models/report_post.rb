class ReportPost < ApplicationRecord
  belongs_to :post
  belongs_to :member_profile
end

# == Schema Information
#
# Table name: report_posts
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
