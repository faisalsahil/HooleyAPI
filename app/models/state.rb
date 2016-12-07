class State < ApplicationRecord
end

# == Schema Information
#
# Table name: states
#
#  id         :integer          not null, primary key
#  country_id :integer
#  name       :string
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
