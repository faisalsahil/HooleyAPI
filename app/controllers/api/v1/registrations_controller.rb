class Api::V1::RegistrationsController < ApplicationController

  api :POST, "/v1/registrations/sign_up.json", "Member SignUp"
  formats ['json', 'xml']
  example <<-EOS
    Request:
    {
      "member_profile":
      {
        "is_profile_public" : false,
        "country_id": 1,
        "gender"    : "male",
        "account_type" : "premium"
        "promotion_updates" : false,
        "dob"               : "12/04/1981",
        "role_id"           : 1,
        "user_attributes":
        {
          "email"     : "android@gmail.com",
          "first_name":"android",
          "last_name" :"android",
          "password"  :"test123456",
          "password_confirmation":"test123456",
          "username"  : "android",

        }
      }
    }
  EOS

  def sign_up
    # params = {
    #     member_profile: {
    #         is_profile_public: false,
    #         account_type: "personal",
    #         gender: "male",
    #         dob: "12/04/1981",
    #         user_attributes: {
    #             email: "omer1@gmail.com",
    #             first_name: "Faisal",
    #             last_name: "CH",
    #             password: "test123456",
    #             password_confirmation: "test123456"
    #         }
    #     }
    # }
    resp_data = MemberProfile.sign_up(params)
    render json: resp_data
  end

  api :POST, '/v1/registrations/sing_up_social_media.json', 'Member SignUp'
  formats ['json', 'xml']
  example <<-EOS
    Request:
    {
      "country_code":"AE",
      "member_profile": {
        "photo"             : "http://www.google.com",
        "gender"            : "male",
        "account_type"      : "premium"
        "promotion_updates" : false,
        "dob"               : "12/04/1981",
        "role_id"           : 1,
        "user_attributes":{
          "email" : "adnan@gmail.com",
          "full_name": "tests",
          "user_authentications_attributes":
          [
            {
              "social_site_id": "hdddslitid",
              "social_site": "facebook"
            }
          ]
        }
      },
      "user_session":{
        "device_uuid":"s96dEBDeDe-ww-AD2-536757E03FB4",
        "device_type":"ios",
        "device_token": "ddddsd-34343"
      }
    }
  EOS

  def sing_up_social_media
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
