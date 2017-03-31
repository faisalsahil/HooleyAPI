class Api::V1::EventWebsController < Api::V1::ApiProtectedController
  
  # calling from web
  def index
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if params[:start_date].present? && params[:end_date].present?
      events       =  Event.where('start_date >= ? AND end_date <= ?', params[:start_date], params[:end_date]).order('start_date DESC')
    else
      events       =  Event.all.order('start_date DESC')
    end
    
    events       =  events.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data  = get_paging_data(params[:page], params[:per_page], events)
    resp_data    = Event.events_response(events, user_session.user)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  def show
    current_user = User.find_by_id(params[:current_user_id])
    profile      = current_user.profile
    event        =  Event.find_by_id(params[:event_id])
    posts        =  event.posts
    posts        =  posts.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data  = get_paging_data(params[:page], params[:per_page], posts)
    resp_data    = Post.posts_array_response(posts, profile)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  def block_event
    event = Event.find_by_id(params[:event_id])
    if event.present?
      event.is_deleted = params[:is_block]
      event.save!
      resp_data    =  {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      resp_data    =  {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'Event not found.'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
end
