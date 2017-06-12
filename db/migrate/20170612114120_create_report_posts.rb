class CreateReportPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :report_posts do |t|
      t.integer :member_profile_id
      t.integer :post_id

      t.timestamps
    end
  end
end
