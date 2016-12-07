class Sport < ApplicationRecord
  has_many :event_sports
  has_many :sport_abbreviations
  has_many :sport_positions
  has_many :events, through: :event_sports



  def self.sport_list(data)
    begin
      data = data.with_indifferent_access
      sports = Sport.all
      if sports.present?
        resp_data = sports_array_response(sports)
        resp_status = 1
        resp_message = 'Sport list'
        resp_errors = ''
      else
        resp_data = sports_array_response(sports)
        resp_status = 1
        resp_message = 'Sport list'
        resp_errors = ''
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.sports_array_response(sports)
    sports = sports.as_json(
        only:    [:id, :name, :image_url],
    )
    { sports: sports }.as_json
  end

  def self.sport_create(data)
    begin
      data = data.with_indifferent_access
      sport = Sport.new(data[:sport])
      sport.save!
      if sport.save
        resp_data = sport
        resp_status = 1
        resp_message = 'Sport created'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 1
        resp_message = 'Something went wrong,Please try again...!'
        resp_errors = ''
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
end
# == Schema Information
#
# Table name: sports
#
#  id         :integer          not null, primary key
#  name       :string
#  image_url  :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
