class UserSportAbbreviation < ApplicationRecord
  belongs_to :member_profile
end

# == Schema Information
#
# Table name: user_sport_abbreviations
#
#  id                    :integer          not null, primary key
#  member_profile_id     :integer
#  sport_abbreviation_id :integer
#  value                 :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
