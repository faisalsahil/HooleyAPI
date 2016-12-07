class CreateHashtags < ActiveRecord::Migration[5.0]
  def change
    create_table :hashtags do |t|
      t.string :name
      t.integer :count, default: 0

      t.timestamps
    end
  end
end
