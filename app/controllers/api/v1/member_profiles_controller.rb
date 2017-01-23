class Api::V1::MemberProfilesController < Api::V1::ApiProtectedController
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
      resp_data = 'Invalid Token'
      return render json: resp_data
    end
  end
end
