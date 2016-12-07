class EventSportMatch < ApplicationRecord
  belongs_to :event_sport
end

# == Schema Information
#
# Table name: event_sport_matches
#
#  id             :integer          not null, primary key
#  title          :string
#  country_id     :integer
#  state_id       :integer
#  city_id        :integer
#  start_date     :datetime
#  end_date       :datetime
#  location       :string
#  description    :text
#  image_url      :string
#  video_url      :string
#  status         :boolean
#  event_sport_id :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
