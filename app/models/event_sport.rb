class EventSport < ApplicationRecord
  belongs_to :event
  belongs_to :sport
  belongs_to :sport_position
  has_many :event_sport_matches
  accepts_nested_attributes_for :event_sport_matches
end

# == Schema Information
#
# Table name: event_sports
#
#  id                :integer          not null, primary key
#  event_id          :integer
#  sport_id          :integer
#  sport_position_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
