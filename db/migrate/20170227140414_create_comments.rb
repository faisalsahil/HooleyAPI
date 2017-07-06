class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.integer :member_profile_id
      t.integer :commentable_id
      t.string  :commentable_type
      # t.boolean :is_deleted, default: :false
      t.text    :comment
      t.timestamps
    end
  end
end
