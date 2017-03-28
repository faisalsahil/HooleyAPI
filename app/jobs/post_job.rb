class PostJob < ApplicationJob
  queue_as :default

  def perform(response, user_ids, post_id=nil, time_line=nil)
    users = []
    unless post_id
      if user_ids.is_a? Fixnum
        if time_line.present?
          users << "post_channel_#{time_line}_#{user_ids}"
        else
          users << "post_channel_#{user_ids}"
        end
      else
        user_ids && user_ids.each do |user_id|
          if time_line.present?
            users << "post_channel_#{time_line}_#{user_ids}"
          else
            users << "post_channel_#{user_ids}"
          end
        end
      end
      ActionCable.server.broadcast_multiple users, response
    else
      users << "post_#{post_id}"
      ActionCable.server.broadcast_multiple users, response
    end
  end
end
