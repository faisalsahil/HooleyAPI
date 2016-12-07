class Api::V1::EventsController < Api::V1::ApiProtectedController

  def event_match
    resp_data = Event.event_search(params, current_user)
    render json: resp_data
  end
  def create
    current_user = User.find_by_id(params[:id])
    resp_data = Event.event_create(params, current_user)
    render json: resp_data
  end

end
