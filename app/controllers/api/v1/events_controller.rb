class Api::V1::EventsController < ApplicationController
  
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

    # params = {
    #     "auth_token": "111111111",
    #     "filter_type": 'invited',
    #     "page": 1,
    #     "per_page": 10,
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
  
  def invited_events
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "search_key": "hello"
    # }
    # user_session = UserSession.find_by_auth_token(params[:auth_token])
    # if user_session.present?
    #   response = Post.discover(params, user_session.user)
    #   render json: response
    # else
    #   resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
    #   return render json: resp_data
    # end
  end
  
  def event_posts
    # params = {
    #   "auth_token": "111111111",
    #   "event_id": 13,
    #   "per_page":10,
    #   "page":1,
    #   "filter_type": "photo"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.event_posts(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
