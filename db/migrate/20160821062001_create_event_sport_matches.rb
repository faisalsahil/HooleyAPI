class CreateEventSportMatches < ActiveRecord::Migration[5.0]
  def change
    create_table :event_sport_matches do |t|
      t.string   :title
      t.integer  :country_id
      t.integer  :state_id
      t.integer  :city_id
      t.datetime :start_date
      t.datetime :end_date
      t.string   :location
      t.text     :description
      t.string   :image_url
      t.string   :video_url
      t.boolean  :status
      t.integer  :event_sport_id
      t.datetime :created_at,   null: false
      t.datetime :updated_at,   null: false
      t.timestamps
    end
  end
end
