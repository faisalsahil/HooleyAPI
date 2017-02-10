class Api::V1::CategoriesController < ApplicationController
  def index
    # params = {
    #   "auth_token": "111111111",
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Category.get_categories(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
end
