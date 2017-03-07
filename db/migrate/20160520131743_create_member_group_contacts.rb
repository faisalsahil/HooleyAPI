class CreateMemberGroupContacts < ActiveRecord::Migration[5.0]
  def change
    create_table :member_group_contacts do |t|
      t.integer :member_group_id
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
