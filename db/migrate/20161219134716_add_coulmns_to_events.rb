class AddCoulmnsToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :is_public, :boolean, default: false
    add_column :events, :event_name, :string
    add_column :events, :latitude, :float
    add_column :events, :longitude, :float
    add_column :events, :radius, :integer
    add_column :events, :event_details, :text
    add_column :events, :is_friends_allowed, :boolean, default: false
    add_column :events, :category_id, :integer
    add_column :events, :is_paid, :boolean, default: false
    add_column :events, :event_type, :string
  end
end
