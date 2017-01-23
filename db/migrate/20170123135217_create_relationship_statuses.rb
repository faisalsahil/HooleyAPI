class CreateRelationshipStatuses < ActiveRecord::Migration[5.0]
  def change
    create_table :relationship_statuses do |t|
      t.string :name

      t.timestamps
    end
  end
end
