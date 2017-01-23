class Api::V1::MemberFollowingsController < ApplicationController
  
  
  def get_followers
    params = {
      "auth_token": "111111111",
      "action": "get_followers",
      "per_page":10,
      "page":1,
      "member_profile":
       {
           "id": 3,
           "search_key": ''
       }
    }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberFollowing.get_followers(params, user_session.user)
      render json: response
    else
      resp_data = 'Invalid Token'
      return render json: resp_data
    end
  end
end
