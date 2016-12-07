class PostJob < ApplicationJob
  queue_as :default

  def perform(response, user_ids, post_id=nil)
    users = []
    unless post_id
      if user_ids.is_a? Fixnum
        users << "post_channel_#{user_ids}"
      else
        user_ids && user_ids.each do |user_id|
          users << "post_channel_#{user_id}"
        end
      end
      ActionCable.server.broadcast_multiple users, response
    else
      users << "post_#{post_id}"
      ActionCable.server.broadcast_multiple users, response
    end
  end
end
