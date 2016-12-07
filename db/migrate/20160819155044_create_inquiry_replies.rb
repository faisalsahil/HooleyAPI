class CreateInquiryReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :inquiry_replies do |t|
      t.integer :enquiry_id
      t.string :name
      t.string :email
      t.string :subject
      t.text :message

      t.timestamps
    end
  end
end
