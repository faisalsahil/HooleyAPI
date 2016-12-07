class Api::V1::UsersController < Api::V1::ApiProtectedController

  api :POST, "/v1/users/get_users_list.json", "Admin Get Users"
  formats ['json', 'xml']
  example <<-EOS
        Request:
        {
          "user_session":{
            "token": "454-545-45-45-454"
          }
        }
        Response:
        {
          "resp_status":"1",
          "message":"Error",
          "errors":"nil",
          "paging_data":"nil",
          "request_id":
            {
              "errors":"User token is expired or does not exist",
               "paging_data":"nil"
            },
              "data":[
                {
                  "id":"1",
                  "email":"ferhan123@gmail.com",
                  "full_name":"fer",
                  "username":"ferhan"
                },
                {
                  "id":"2",
                  "email":"fani@gmail.com",
                  "full_name":"fer",
                  "username":"ferhan"
                }
                     ]
        }
  EOS


  def get_users_list
    per_page = (params[:per_page] || @@limit).to_i
    page     = (params[:page] || 1).to_i

    users        =User.where(profile_type: "MemberProfile", is_deleted: false)
    users        = users.page(page.to_i).per_page(per_page.to_i)
    resp_data    = user_response(users)
    paging_data  = get_paging_data(page, per_page, users)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end


  def user_response(users_array)
    users_array.as_json(
        only: [:id, :username, :email, :full_name]
    )
  end

  def destroy
    user           = User.find_by_id(params[:id])
    user.is_deleted= true
    user.save!
    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end


end
