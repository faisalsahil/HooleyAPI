class Api::V1::UserSessionsController < ApplicationController
  # layout 'email_layout'
  # respond_to :json

  # include UsersHelper
  before_filter :load_user_using_perishable_token, only: [:edit_password_reset, :update_password]


  api :POST, "/v1/user_sessions/login.json", "Login"
  formats ['json', 'xml']
  example <<-EOS
        Request:
        {
          "user":{
            "email":"adnan@email.com",
            "password":"123456"
          }
        }

  EOS

  def login
    resp_data = User.sign_in(params)
    render json: resp_data
  end

  api :POST, "/v1/user_sessions/forget_password.json", "Forget password"
  formats ['json', 'xml']
  example <<-EOS
        Request:
        {
          "email":"email@gmail.com"
        }

        Response:
        {
           "resp_status":1,
           "message":"Instructions to reset your password have been emailed to you, follow instructions mentioned",
           "errors":null,
           "data":""
        }
  EOS
  # param :email, String, desc: "User's email", required: true


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
