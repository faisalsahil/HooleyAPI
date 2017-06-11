class Api::V1::FavouritesController < ApplicationController
  
  def add_to_favourite
    # params = {
    #     "auth_token": UserSession.last.auth_token,
    #     "favourites_attributes": [
    #         {
    #            "event_id": 1
    #         },
    #         {
    #             "event_id": 2
    #         }
    #     ]
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Favourite.add_to_favourite(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
