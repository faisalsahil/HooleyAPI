class SportAbbreviation < ApplicationRecord
  belongs_to :sport

  def self.sport_abbreviation_list(data)
    begin
      data = data.with_indifferent_access
      sport_abbreviations = SportAbbreviation.all
      resp_data = sport_abbreviation_array_response(sport_abbreviations)
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

  def self.sport_abbreviation_array_response(sport_abbreviations)
    sport_abbreviations = sport_abbreviations.as_json(
        only:    [:id, :sport_id, :title, :description, :image_url, :user_id],
    )
    { sport_abbreviations: sport_abbreviations }.as_json
  end

  def self.sport_abbreviation_create(data)
    begin
      data = data.with_indifferent_access
      sport_abbreviation = SportAbbreviation.new(data[:sport_abbreviation])
      sport_abbreviation.save!
      if sport_abbreviation.save!
        resp_data = sport_abbreviation
        resp_status = 1
        resp_message = 'Sport abbreviation created'
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
# Table name: sport_abbreviations
#
#  id          :integer          not null, primary key
#  sport_id    :integer
#  title       :string
#  description :string
#  image_url   :string
#  user_id     :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
