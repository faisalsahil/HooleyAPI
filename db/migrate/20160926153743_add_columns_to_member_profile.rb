class AddColumnsToMemberProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :height, :float
    add_column :member_profiles, :weight, :float
  end
end
