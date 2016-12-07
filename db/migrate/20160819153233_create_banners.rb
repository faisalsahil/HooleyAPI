class CreateBanners < ActiveRecord::Migration[5.0]
  def change
    create_table :banners do |t|
      t.string :title
      t.string :alt_text
      t.string :url
      t.text :detail
      t.string :path
      t.datetime :from_date
      t.datetime :to_date
      t.boolean :active
      t.boolean :default_photo
      t.boolean :show_at_home
      t.integer :sequence
      t.integer :user_id

      t.timestamps
    end
  end
end
