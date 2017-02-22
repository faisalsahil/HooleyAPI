class RemoveAndAddVisitingStatusFields < ActiveRecord::Migration[5.0]
  def change
    remove_column :event_members, :on_the_way
    remove_column :event_members, :reached
    remove_column :event_members, :gone
    add_column :event_members, :visiting_status, :string, default: nil
  end
end
