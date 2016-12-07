class CreateUserSportAbbreviations < ActiveRecord::Migration[5.0]
  def change
    create_table :user_sport_abbreviations do |t|
      t.integer :member_profile_id
      t.integer :sport_abbreviation_id
      t.string :value

      t.timestamps
    end
  end
end
