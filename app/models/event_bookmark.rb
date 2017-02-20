class EventBookmark < ApplicationRecord
  
  belongs_to :member_profile
  
  def self.is_bookmarked(event, profile_id)
    is_marked = EventBookmark.where(member_profile_id: profile_id, event_id: event.id).try(:first)
    if is_marked.present?
      true
    else
      false
    end
  end
  
  def self.add_or_cancel_bookmark(data, current_user)
    begin
      data           = data.with_indifferent_access
      member_profile = current_user.profile
      bookmark       = EventBookmark.where(event_id: data[:event_bookmark][:event_id], member_profile_id: member_profile.id).try(:first)
      if !bookmark.present?
        bookmark     = member_profile.event_bookmarks.build(data[:event_bookmark])
      end
      
      if bookmark.new_record? && bookmark.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      elsif bookmark.update_attributes(data[:event_bookmark])
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'error'
        resp_errors     = 'Bookmark not save.'
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
