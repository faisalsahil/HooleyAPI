class SportPosition < ApplicationRecord
  has_many :event_sports
  belongs_to :sport

  def self.sport_position_list(data)
    begin
      data = data.with_indifferent_access
      sport_positions = SportPosition.all
      resp_data = sport_position_array_response(sport_positions)
      resp_status = 1
      resp_message = 'Sport Abbreviations list'
      resp_errors = ''
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

  def self.sport_position_array_response(sport_positions)
    sport_positions = sport_positions.as_json(
        only:    [:id, :name],
    )
    { sport_positions: sport_positions }.as_json
  end

  def self.sport_position_create(data)
    begin
      data = data.with_indifferent_access
      sport_position = SportPosition.new(data[:sport_position])
      sport_position.save!
      if sport_position.save!
        resp_data = sport_position
        resp_status = 1
        resp_message = 'Sport position created'
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
# Table name: sport_positions
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
