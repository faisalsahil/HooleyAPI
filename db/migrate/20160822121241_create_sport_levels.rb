class CreateSportLevels < ActiveRecord::Migration[5.0]
  def change
    create_table :sport_levels do |t|
      t.string :name

      t.timestamps
    end
  end
end
