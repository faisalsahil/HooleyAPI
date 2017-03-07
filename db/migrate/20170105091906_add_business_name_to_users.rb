class AddBusinessNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :business_name, :string
  end
end
