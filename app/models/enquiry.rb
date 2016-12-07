class Enquiry < ApplicationRecord
end

# == Schema Information
#
# Table name: enquiries
#
#  id         :integer          not null, primary key
#  name       :string
#  email      :string
#  phone      :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
