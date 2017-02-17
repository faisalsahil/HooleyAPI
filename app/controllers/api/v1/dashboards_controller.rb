class Api::V1::DashboardsController < Api::V1::ApiProtectedController
  
  # call from web
  def index
    posts         =  Post.count
    events        =  Event.count
    today_events  =  Event.where('Date(start_date) = ?',  Date.today).count
    yesterday_events = Event.where('Date(start_date) = ?',  Date.today - 1.day).count
    users         = User.count
    resp_data     =  {users: users, posts: posts, events: events, today_events: today_events, yesterday_events: yesterday_events}.as_json
    resp_status   = 1
    resp_message  = 'Success'
    resp_errors   = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
end
