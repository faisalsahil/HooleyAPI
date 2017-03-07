class AddColumnsToSynchronizations < ActiveRecord::Migration[5.0]
  def change
    add_column :synchronizations, :media_id, :integer
    add_column :synchronizations, :media_type, :string
  end
end
