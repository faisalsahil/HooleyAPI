class Api::V1::AdminProfilesController < Api::V1::ApiProtectedController

  # load_and_authorize_resource
  def edit
    resp_data    = AdminProfile.find_by_id(params[:id]).admin_profile(0)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end


  def update
    admin_profile = AdminProfile.find_by_id(params[:id])
    admin_profile.update_attributes(profile_params)

    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  private
  def profile_params
    params.require(:admin_profile).permit(:about, :phone, user_attributes: [:id, :full_name])

  end
end
