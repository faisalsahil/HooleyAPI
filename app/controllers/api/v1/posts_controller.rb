class Api::V1::PostsController < Api::V1::ApiProtectedController
  
  def discover
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "search":
    #   {
    #     "type": "Hashtag"
    #   }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Post.discover(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
