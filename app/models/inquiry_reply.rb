class InquiryReply < ApplicationRecord
end

# == Schema Information
#
# Table name: inquiry_replies
#
#  id         :integer          not null, primary key
#  enquiry_id :integer
#  name       :string
#  email      :string
#  subject    :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
