class CreateCities < ActiveRecord::Migration[5.0]
  def change
    create_table :cities do |t|
      t.integer :country_id
      t.integer :state_id
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
