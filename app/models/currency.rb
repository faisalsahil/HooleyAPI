class Currency < ApplicationRecord
  belongs_to :country
end

# == Schema Information
#
# Table name: currencies
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  country_id :integer
#
