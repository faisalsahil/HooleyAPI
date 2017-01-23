class CreateEthnicBackgrounds < ActiveRecord::Migration[5.0]
  def change
    create_table :ethnic_backgrounds do |t|
      t.string :name

      t.timestamps
    end
  end
end
