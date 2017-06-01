class AddHandlerToMemberProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :member_profiles, :handler, :string
  end
end
