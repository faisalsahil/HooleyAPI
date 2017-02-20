class AddStatusToEventMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :event_members, :invitation_status, :string, default: 'invited'
  end
end
