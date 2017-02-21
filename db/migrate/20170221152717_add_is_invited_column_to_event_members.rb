class AddIsInvitedColumnToEventMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :event_members, :is_invited, :boolean, default: false
  end
end
