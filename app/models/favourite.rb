class Favourite < ApplicationRecord
  
  belongs_to :member_profile
  belongs_to :post
  
  def self.add_to_favourite(data, current_user)
    begin
      data = data.with_indifferent_access
      member_profile = current_user.profile
        member_profile.favourites.build(data[:favourites_attributes])
      if member_profile.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Favourite not added. something went wrong.'
        resp_errors     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.favourites_list
    begin
      member_profile = current_user.profile
      member_profile.favourites
      if true
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Favourite not added. something went wrong.'
        resp_errors     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
end
