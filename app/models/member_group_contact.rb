class MemberGroupContact < ApplicationRecord
  belongs_to :member_group
  belongs_to :member_profile


end

# == Schema Information
#
# Table name: member_group_contacts
#
#  id                :integer          not null, primary key
#  member_group_id   :integer
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
