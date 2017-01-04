class EventCoHost < ApplicationRecord
  belongs_to :event
  
  def self.is_co_host_or_host(post, member_profile_id)
    binding.pry
    if post.event.member_profile_id == member_profile_id
      return 1
    elsif EventCoHost.find_by_event_id_and_member_profile_id(post.event_id, member_profile_id).present?
      return 2
    else
      return 0
    end
  end
end
