class CreateMemberGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :member_groups do |t|
      t.integer :member_profile_id
      t.string :group_name
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
