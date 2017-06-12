class Api::V1::ReportPostsController < ApplicationController
  
  def create
    # params = {
    #   "auth_token": UserSession.last.auth_token,
    #   "post_id": 1
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = ReportPost.report_a_post(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
