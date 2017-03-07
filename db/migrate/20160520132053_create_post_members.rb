class CreatePostMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :post_members do |t|
      t.integer :post_id
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
