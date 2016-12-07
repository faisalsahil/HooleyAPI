class AddCoverFieldToMemberProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :cover, :string
  end
end
