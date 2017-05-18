class AddUsernameEmailToUserAuthentications < ActiveRecord::Migration[5.0]
  def change
    add_column :user_authentications, :username, :string
    add_column :user_authentications, :email, :string
  end
end
