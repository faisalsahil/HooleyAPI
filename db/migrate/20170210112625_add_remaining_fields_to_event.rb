class AddRemainingFieldsToEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :custom_skin, :string
    add_column :events, :message_from_host, :string
  end
end
