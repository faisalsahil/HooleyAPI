class Api::V1::EventsController < ApplicationController
  
  def index
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'search',
    #     "keyword": 'chuburji pakistan',
    #     "location": '',
    #     "date": '2017-01-26',
    #     "radius": 5,
    #     "latitude": "31.556216",
    #     "longitude": "74.294954",
    #     "category_id": 1,
    #     "is_paid": true
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.event_list(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def event_list_horizontal
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'day',
    # }
    
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'np_day',
    # }
    #
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'week',
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'all',
    # }
    
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 2,
    #     "per_page": 10,
    #     "list_type": 'day',
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'np_day',
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'week',
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'all',
    # }
    
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'search',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": '',
    #     "keyword": 'chuburji pakistan',
    #     "location": '',
    #     "date": '2017-01-26',
    #     "radius": 5,
    #     "latitude": "31.556216",
    #     "longitude": "74.294954",
    #     "category_id": 1,
    #     "is_paid": true
    # }

    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.event_list_horizontal(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
