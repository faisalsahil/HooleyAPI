class Api::V1::EventBookmarksController < ApplicationController
  
  def create
    # params = {
    #     "auth_token": "111111111",
    #     "event_bookmark":{
    #         event_id: 13,
    #         is_bookmark: false
    #     }
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = EventBookmark.add_or_cancel_bookmark(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
