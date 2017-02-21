class Api::V1::EventsController < ApplicationController
  include AppConstants
  
  def event_list_horizontal
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'day',
    #     "filter_type": 'invited/registered/bookmarked'
    # }
    
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'np_day',
    #     "filter_type": 'invited/bookmarked',
    # }
    #
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'week',
    #     "filter_type": 'invited/bookmarked'
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'upcoming',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'all',
    #     "filter_type": 'invited/bookmarked'
    # }
    
    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 2,
    #     "per_page": 10,
    #     "list_type": 'day',
    #     "filter_type": 'invited/bookmarked'
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'np_day',
    #     "filter_type": 'invited/bookmarked'
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'week',
    #     "filter_type": 'invited/bookmarked'
    # }

    # params = {
    #     "auth_token": "111111111",
    #     "type": 'past',
    #     "page": 1,
    #     "per_page": 10,
    #     "list_type": 'all',
    #     "filter_type": 'registered'
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
  
  def event_register
    # params = {
    #   "auth_token": "111111111",
    #   "event_id": 13,
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    current_user = user_session.user
    if user_session.present?
      event_member =  EventMember.find_by_event_id_and_member_profile_id(params[:event_id], current_user.profile_id)
      if !event_member.present?
        event_member = EventMember.new
        event_member.member_profile_id = current_user.profile_id
        event_member.event_id  = params[:event_id]
      end
      event_member.invitation_status = AppConstants::REGISTERED
      if event_member.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Registered.'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'Not registered'
      end
      response = {resp_data: resp_data, resp_status: resp_status, resp_message: resp_message, resp_error: resp_errors}.as_json
      render json: response
    else
      response = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: response
    end
  end
  
  def profile_events
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "member_profile_id": 4,
    #   "search_key": "chuburji"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.profile_events(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def event_guests
    params = {
      "auth_token": "111111111",
      "per_page":10,
      "page":1,
      "event_id": 13,
      "type": "registered",
      # "type": "registered/on_way/here_now/gone/",
      # "filter_type": "male",
      # "search_key": "faisal"
    }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.event_guests(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def event_attending_status
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "event_id": 13,
    #   "on_the_way": true,
    #   "reached":    true,
    #   "gone":       true
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Event.event_attending_status(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  def event_add_members
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "event": {
    #       "id": 13,
    #       "event_members_attributes":[
    #            {
    #                "member_profile_id": 6,
    #                "is_invited": true
    #            },
    #            {
    #                "member_profile_id": 7,
    #                "is_invited": true
    #            }
    #       ]
    #   }
    #
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      event = Event.find_by_id(params[:event][:id])
      if event.present? && event.update_attributes(params[:event])
        response = {resp_data: {}, resp_status: 1, resp_message: 'success', resp_error: ''}.as_json
      else
        response = {resp_data: {}, resp_status: 0, resp_message: 'error', resp_error: 'Members not added'}.as_json
      end
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
