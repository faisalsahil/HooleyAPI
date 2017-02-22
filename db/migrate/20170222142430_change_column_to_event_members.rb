class ChangeColumnToEventMembers < ActiveRecord::Migration[5.0]
  def change
    remove_column :event_members, :visiting_status
    add_column :event_members,    :visiting_status, :string, default: 'not_invited'
  end
end
