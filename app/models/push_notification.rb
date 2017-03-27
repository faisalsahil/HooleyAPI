class PushNotification < ApplicationRecord
  include JsonBuilder
  belongs_to :user
  @@limit = 10
  
  def self.notification_list(data, user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      
      notifications  = user.push_notifications.order('created_at DESC')
      notifications  = notifications.page(page.to_i).per_page(per_page.to_i)
      paging_data    = JsonBuilder.get_paging_data(page, per_page, notifications)
      if notifications.present?
        resp_data    = notification_list_response(notifications)
      else
        resp_data    = {}
      end
      resp_status    = 1
      resp_message   = 'Notification List'
      resp_errors    = ''
    rescue Exception => e
      resp_data      = {}
      resp_status    = 0
      paging_data    = ''
      resp_message   = 'error'
      resp_errors    = e
    end
    resp_request_id = ''
    if data[:request_id].present?
      resp_request_id   = data[:request_id]
    end
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
  
  def self.notification_list_response(notifications)
    notifications = notifications.as_json(
        only:[:id, :alert, :badge, :screen, :screen_data, :created_at, :updated_at],
        include:{
            user:{
                only:[:id, :username],
                include:{
                    profile:{
                        only: [:id, :photo]
                    }
                }
            }
        }
    )
    {notifications: notifications}.as_json
  end
end
