class CreateSynchronizations < ActiveRecord::Migration[5.0]
  def change
    create_table :synchronizations do |t|
      t.integer     :member_profile_id
      t.string      :sync_token
      t.string      :sync_type
      t.datetime    :synced_date


      t.timestamps
    end
  end
end
