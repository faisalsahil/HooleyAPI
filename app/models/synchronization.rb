class Synchronization < ApplicationRecord
  belongs_to :member_profile
  belongs_to :media, polymorphic: true
end

# == Schema Information
#
# Table name: synchronizations
#
#  id                :integer          not null, primary key
#  member_profile_id :integer
#  sync_token        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  synced_date       :datetime
#  sync_type         :string
#
