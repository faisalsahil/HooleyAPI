class RemoveExtraColumnFromDb < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :username
    remove_column :users, :full_name
    remove_column :member_profiles, :about
    remove_column :member_profiles, :phone
  end
end
