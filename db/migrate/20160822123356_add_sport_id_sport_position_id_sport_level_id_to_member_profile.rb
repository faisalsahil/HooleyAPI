class AddSportIdSportPositionIdSportLevelIdToMemberProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :sport_id, :integer
    add_column :member_profiles, :sport_position_id, :integer
    add_column :member_profiles, :sport_level_id, :integer
  end
end
