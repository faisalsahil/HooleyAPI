class Api::V1::PushNotificationsController < ApplicationController
  def index
    # params = {
    #     auth_token: '1234567890',
    #     page: 1,
    #     per_page: 10
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = PushNotification.notification_list(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_status: 0, message: 'Invalid Token', error: '', data: {}}
      return render json: resp_data
    end
  end
end
