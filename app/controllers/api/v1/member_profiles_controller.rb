class Api::V1::MemberProfilesController < ApplicationController
  # load_and_authorize_resource
  
  def get_profile
    # params = {
    #     "auth_token": "111111111",
    #     "member_profile_id": 3
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberProfile.get_profile(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def profile_timeline
    # params = {
    #     "auth_token": "111111111",
    #     "page": 1,
    #     "per_page": 10,
    #     "member_profile_id": 4,
    #     "filter_type": "video",
    #     "type": "near_me",
    #     "latitude":  "23.232323",
    #     "longitude": "23.2323223"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberProfile.profile_timeline(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def dropdown_data
    # params = {
    #     "auth_token": "111111111"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = MemberProfile.get_drop_down_data(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end

  def update_user_location
    # params = {
    #     "auth_token":  "111111111",
    #     "member_profile": {
    #         "latitude":  44.44,
    #         "longitude": 555.555
    #     }
    # }
  
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = MemberProfile.update_user_location(params, user_session.user)
      return render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
