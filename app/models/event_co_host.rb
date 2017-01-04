class EventCoHost < ApplicationRecord
  belongs_to :event
  
  def self.is_co_host_or_host(post, recent_post_comment)
    if post.event.member_profile_id == recent_post_comment.member_profile_id
      return 1
    elsif EventCoHost.find_by_event_id_and_member_profile_id(post.event_id, member_profile_id).present?
      return 2
    else
      return 0
    end
  end
end
