class AdminJob < ApplicationJob
  queue_as :default

  # def perform(response, user_ids)
  #   users = []
  #   user_ids.each do |user_id|
  #     users << "admin_channel_#{user_id}"
  #   end
  # end
  # ActionCable.server.broadcast_multiple users, respon
end

