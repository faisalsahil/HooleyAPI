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

  def self.is_invited(event, profile_id)
    event_member = EventMember.where(member_profile_id: profile_id, event_id: event.id).try(:first)
    if event_member.present? && event_member.invitation_status == AppConstants::INVITED
      true
    else
      false
    end
  end

  def self.visiting_status(event, profile_id)
    event_member = EventMember.where(member_profile_id: profile_id, event_id: event.id).try(:first)
    if event_member.present?
      if event_member.present? && event_member.gone.present?
        1
      elsif event_member.present? && event_member.reached.present?
        2
      elsif event_member.present? && event_member.on_the_way.present?
        3
      end
    else
      0
    end
  end
end
