class EventMember < ApplicationRecord
  
  belongs_to :event
  belongs_to :member_profile

  def self.is_registered(event, profile_id)
    event_member = EventMember.where(member_profile_id: profile_id, event_id: event.id).try(:first)
    if event_member.present? && event_member.invitation_status == AppConstants::REGISTERED
      true
    else
      false
    end
  end

  def self.visiting_status(event, profile_id)
    event_member = EventMember.find_by_member_profile_id_and_event_id(profile_id, event.id)
    if event_member.present?
      event_member.visiting_status
    else
      "not_invited"
    end
  end
end
