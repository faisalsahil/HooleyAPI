class UsersController < ApplicationController
  
  def activation
    user = User.find_by_authentication_token(params[:authentication_token])
    if user.present?
      user.authentication_token = nil
      user.is_account_active    = true
      user.save!
      @success = true
    else
      @success = false
    end
  end
end
