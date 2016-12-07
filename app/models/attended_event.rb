class AttendedEvent < ApplicationRecord
  belongs_to :member_profile

  def self.attend_event(data, current_user)
    begin
      data    = data.with_indifferent_access
      profile = current_user.profile
      attended_event   = profile.attended_events.build(data[:event])
      if attended_event.save
        resp_data       = ''
        resp_status     = 1
        resp_message    = 'Event Attended'
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Event not Found'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id)
  end


end
