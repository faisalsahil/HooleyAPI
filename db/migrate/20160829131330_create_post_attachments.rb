class CreatePostAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :post_attachments do |t|
      t.integer :post_id
      t.string :attachment_url
      t.string :thumbnail_url
      t.string :attachment_type

      t.timestamps
    end
  end
end
