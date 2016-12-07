class CreateReports < ActiveRecord::Migration[5.0]
  def change
    create_table :reports do |t|
      t.text :comment
      t.integer :reportable_id
      t.string :reportable_type
      t.integer :member_profile_id

      t.timestamps
    end
  end
end
