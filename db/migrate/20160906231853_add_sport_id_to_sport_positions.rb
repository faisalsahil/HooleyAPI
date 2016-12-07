class AddSportIdToSportPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :sport_positions, :sport_id, :integer
  end
end
