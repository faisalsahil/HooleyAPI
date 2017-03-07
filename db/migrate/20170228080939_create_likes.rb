class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.integer :member_profile_id
      t.integer :likable_id
      t.string  :likable_type
      t.boolean :is_like,    default:  true
      t.boolean :is_deleted, default:  false
      t.timestamps
    end
  end
end
