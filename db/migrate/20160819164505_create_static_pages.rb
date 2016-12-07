class CreateStaticPages < ActiveRecord::Migration[5.0]
  def change
    create_table :static_pages do |t|
      t.string :title
      t.text :content
      t.text :page_keyword
      t.text :page_description
      t.string :content_for
      t.integer :user_id

      t.timestamps
    end
  end
end
