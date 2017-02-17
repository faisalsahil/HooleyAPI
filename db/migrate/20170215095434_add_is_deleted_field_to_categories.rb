class AddIsDeletedFieldToCategories < ActiveRecord::Migration[5.0]
  def change
    add_column :categories, :is_deleted, :boolean, default: false
  end
end
