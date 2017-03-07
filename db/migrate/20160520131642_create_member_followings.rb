class CreateMemberFollowings < ActiveRecord::Migration[5.0]
  def change
    create_table :member_followings do |t|
      t.integer :member_profile_id
      t.integer :following_profile_id
      t.string :following_status, default: 'pending'
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
