class CreateReportComments < ActiveRecord::Migration[5.0]
  def change
    create_table :report_comments do |t|
      t.integer :post_comment_id
      t.integer :member_profile_id
      t.text :comment

      t.timestamps
    end
  end
end
