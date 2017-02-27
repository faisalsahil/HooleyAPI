class EventJob < ApplicationJob
  queue_as :default
  
  def perform(response, event_id)
    users = []
    users << "event_#{event_id}"
    ActionCable.server.broadcast_multiple users, response
  end
end

