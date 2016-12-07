class CreateStates < ActiveRecord::Migration[5.0]
  def change
    create_table :states do |t|
      t.integer :country_id
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
