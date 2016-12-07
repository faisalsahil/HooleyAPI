class CreateReportPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :report_posts do |t|
      t.integer :post_id
      t.integer :member_profile_id
      t.text :comment

      t.timestamps
    end
  end
end
