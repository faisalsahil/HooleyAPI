class AddUserStatusFieldsToEventMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :event_members, :on_the_way, :boolean, default: false
    add_column :event_members, :reached,    :boolean, default: false
    add_column :event_members, :gone,       :boolean, default: false
  end
end
