class Api::V1::UsersController < Api::V1::ApiProtectedController
  
  def index
    users       =  User.all
    users       =  users.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data = get_paging_data(params[:page], params[:per_page], users)
    users       =  users.as_json(
        only: [:id, :profile_id, :profile_type, :first_name, :email, :last_name, :phone],
        include:{
            profile:{
                only: [:id, :photo, :country_id, :city_id, :is_profile_public, :default_group_id, :gender, :dob, :account_type, :high_school, :is_age_visible, :gender, :current_city, :home_town, :employer, :college, :high_school, :organization, :hobbies,:contact_email, :contact_phone, :contact_website, :contact_address],
            }
        }
    )
    resp_data    = {users: users}.as_json
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
end
