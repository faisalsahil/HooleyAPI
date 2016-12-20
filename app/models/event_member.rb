class EventMember < ApplicationRecord
  belongs_to :event
  belongs_to :member_profile
end
