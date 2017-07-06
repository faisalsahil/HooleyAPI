class EventsController < ApplicationController
  layout false
  def show
    @event   = Event.find_by_id(params[:id])
    @profile = @event.member_profile
    @user    = @profile.user
  end
end
