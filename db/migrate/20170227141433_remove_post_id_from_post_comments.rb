class RemovePostIdFromPostComments < ActiveRecord::Migration[5.0]
  def change
    remove_column :post_comments, :post_id
  end
end
