class CreateSportAbbreviations < ActiveRecord::Migration[5.0]
  def change
    create_table :sport_abbreviations do |t|
      t.integer :sport_id
      t.string :title
      t.string :description
      t.string :image_url
      t.integer :user_id

      t.timestamps
    end
  end
end
