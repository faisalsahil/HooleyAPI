class City < ApplicationRecord
end

# == Schema Information
#
# Table name: cities
#
#  id         :integer          not null, primary key
#  country_id :integer
#  state_id   :integer
#  name       :string
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
