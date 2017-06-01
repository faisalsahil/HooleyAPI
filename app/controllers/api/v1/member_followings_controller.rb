class Api::V1::MemberFollowingsController < ApplicationController
  
  def search_member
    # params ={
    #   auth_token: UserSession.last.auth_token,
    #   "per_page": 10,
    #   "page": 1,
    #   "search_key": ""
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = MemberFollowing.search_member(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end
  
  def get_followers
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "member_profile_id": 3,
    #   "search_key": 'F'
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberFollowing.get_followers(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def get_following_requests
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberFollowing.get_following_requests(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
