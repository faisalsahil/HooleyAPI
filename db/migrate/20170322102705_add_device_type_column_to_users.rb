class AddDeviceTypeColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :device_type, :string
    add_column :users, :device_token, :string
  end
end
