class AddSchoolToMemberProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :school, :string
  end
end
