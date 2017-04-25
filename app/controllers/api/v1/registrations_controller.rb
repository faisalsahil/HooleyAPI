class Api::V1::RegistrationsController < ApplicationController

  def sign_up
    # params = {
    #     member_profile: {
    #         is_profile_public: false,
    #         account_type: "personal",
    #         gender: "male",
    #         dob: "12/04/1981",
    #         user_attributes: {
    #             email: "test3@gmail.com",
    #             first_name: "Test3",
    #             last_name: "Testing",
    #             password: "test123456",
    #             password_confirmation: "test123456"
    #         }
    #     }
    # }
    resp_data = MemberProfile.sign_up(params)
    render json: resp_data
  end

  def sing_up_social_media
    # params = {
    #     "member_profile": {
    #         "is_profile_public": true,
    #         "user_attributes": {
    #             "username": "faisalbhatti",
    #             # "username": "",
    #             "user_authentications_attributes": [
    #                {
    #                    "social_site_id": "2323223223232",
    #                    "social_site": "facebook",
    #                    "social_site_token": "2345678987654"
    #                }
    #             ]
    #         }
    #     },
    #     "user_session": {
    #         "device_uuid": "s96dEBDeDe-ww-AD2-536757E03FB4",
    #         "device_type": "ios",
    #         "device_token": "ddddsd-34343"
    #     }
    # }
    resp_data = MemberProfile.social_media_sign_up(params)
    render json: resp_data
  end


  api :POST, '/v1/registrations/forgot_password.json', 'Forgot Password'
  formats ['json', 'xml']
  example <<-EOS
    Request:
    {
      "user":
      {
        "email": "test@gmail.com"
      }
    }
  EOS

  def forgot_password
    resp_data = User.forgot_password(params)
    render json: resp_data
  end

end
