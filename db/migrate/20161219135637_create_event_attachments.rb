class CreateEventAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :event_attachments do |t|
      t.string :attachment_type
      t.text :message
      t.string :attachment_url
      t.string :thumbnail_url
      t.string :poster_skin
      t.integer :event_id

      t.timestamps
    end
  end
end
