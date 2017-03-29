class ChangeColumnTypeIntoMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    change_column :member_profiles, :near_event_search, :float, default: 5.0
  end
end
