class AddIsAccountActiveFieldToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :is_account_active, :boolean, default: false
  end
end
