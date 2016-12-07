class AddAttachmentTypeToPostAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :post_attachments, :attachment_type, :string
  end
end
