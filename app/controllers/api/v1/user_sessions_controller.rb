class Api::V1::UserSessionsController < ApplicationController
  before_filter :load_user_using_perishable_token, only: [:edit_password_reset, :update_password]
  
  def login
    # params = {
    #     "user":{
    #         "email":"test3@gmail.com",
    #         "password":"test123456"
    #     },
    #     "user_session": {
    #         "device_uuid": "vBD-y53ED85-FB4",
    #         "device_type": "ios",
    #         "device_token": "637vvs6-6-6-6-6-6-7"
    #     }
    # }
    resp_data = User.sign_in(params)
    render json: resp_data
  end
  
  def destroy
    user_session = UserSession.find_by_auth_token(params[:id])
    if user_session.present?
      user_session.session_status = 'close'
      user_session.save!
    end
    true
  end

  private

  def load_user_using_perishable_token
    @user = User.find_by_perishable_token(params[:token])
  end

end
