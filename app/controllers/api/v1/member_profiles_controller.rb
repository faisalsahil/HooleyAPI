class Api::V1::MemberProfilesController < Api::V1::ApiProtectedController
  # load_and_authorize_resource

  def index
    resp_data = MemberProfile.user_list(current_user, params)
    return render json: resp_data
  end

  def member_profile
    resp_data    = User.find_by_id(params[:user_id]).profile.member_profile(0)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def update
    current_user = MemberProfile.find_by_id(params[:member_profile_id]).user
    resp_data    = MemberProfile.update(params, current_user)
    render json: resp_data
  end

  def edit
    member_profile = MemberProfile.find_by_id(params[:id])
    if member_profile.present?
      member_profile = member_profile.as_json(
          only:    [:id, :about, :phone, :country_id, :state, :is_profile_public, :dob, :gender, :account_type],
          include: {
              user: {
                  only:    [:id, :email, :profile_id, :profile_type, :user_status, :authentication_token, :banner_image_1, :banner_image_2, :banner_image_3, :promotion, :is_deleted, :first_name, :last_name, :retype_email, :role_id],
                  include: {
                      role: {
                          only: [:id, :name]
                      }
                  }
              }
          }
      )
      return render json: member_profile
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'No Member Found'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def find_athlete
    role            = Role.find_by_name('Athlete')
    name            = params[:name]
    country         = params[:country_id]
    state           = params[:state_id]
    city            = params[:city_id]
    sport           = params[:sport_id]
    sport_position  = params[:sport_position_id]
    users           = User.where("first_name like :q or last_name like :q or email like :q", q: "%#{name}%")
    users           = users.where(role_id: role.id)
    profile_ids     = users.pluck(:profile_id)
    member_profiles = MemberProfile.where(id: profile_ids, country_id: country, state_id: state, city_id: city, sport_id: sport, sport_position_id: sport_position)
    if member_profiles.present?
      resp_data    = member_profiles_response(member_profiles)
      resp_status  = 1
      resp_message = 'Athlete List'
      resp_errors  = ''
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'No Athlete Found'
      resp_errors  = ''
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def find_coach
    role            = Role.find_by_name('Coach')
    state           = params[:state_id]
    school          = params[:school]
    sport           = params[:sport_id]
    division        = params[:division]
    gender          = params[:gender]
    users           = User.where(role_id: role.id)
    profile_ids     = users.pluck(:profile_id)
    member_profiles = MemberProfile.where(id: profile_ids, gender: gender, state_id: state, sport_id: sport)
    if member_profiles.present?
      resp_data    = member_profiles_response(member_profiles)
      resp_status  = 1
      resp_message = 'Coach List'
      resp_errors  = ''
    else
      resp_data    = member_profiles_response(member_profiles)
      resp_status  = 0
      resp_message = 'No coach Found'
      resp_errors  = ''
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def member_profiles_response(member_profiles)
    member_profiles = member_profiles.as_json(
        only:    [:id, :photo, :gender],
        include: {
            user: {
                only:    [:id, :first_name, :last_name, :email, :role_id],
                include: {
                    role: {
                        only: [:id, :name]
                    }
                }
            }
        }
    )
    { member_profiles: member_profiles }.as_json
  end

  def destroy
    user = User.find_by_id(params[:id])
    if user.present?
       user.destroy
       resp_data    = ''
       resp_status  = 1
       resp_message = 'success'
       resp_errors  = ''
       common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end

  end

  def show
    user = User.find_by_id(params[:id])
    if user.present?
      user = user.as_json(
          only: [:id,:email, :profile_id,:profile_type,:user_status,:authentication_token,:banner_image_1,:banner_image_2,:banner_image_3,:promotion,:is_deleted,:first_name,:last_name, :retype_email,:role_id],
          include:{
              role:{
                  only:[:id, :name]
              }

          }
      )
      user = { user: user }.as_json
      resp_data    = user
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
     common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def post_list
    profile = User.find_by_id(params[:id]).try(:profile)
    if profile.present?
      posts = profile.posts
      posts = posts.as_json(
          only: [:id, :post_title, :post_description, :datetime, :is_post_public, :is_deleted, :created_at, :updated_at, :post_type, :location, :latitude, :longitude],

      )
      posts = { posts: posts }.as_json

      resp_data    = posts
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'User not exist'
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def user_list
    users = User.all
    if users.present?
      users = users.as_json(
          only: [:id, :email, :profile_type, :user_status, :gender, :first_name, :last_name, :role_id]
      )
      users = { users: users }.as_json

      resp_data    = users
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'User not exist'
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end

  end
  
  def profile_timeline
    # params = {
    #     auth_token: "12121212121212",
    #     page: 1,
    #     per_page: 10,
    #     member_profile_id: 2
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    # user_session = UserSession.last
    if user_session.present?
      resp_data = MemberProfile.profile_timeline(params, user_session.user)
      return render json: resp_data
    else
      resp_data = 'Invalid Token'
      return render json: resp_data
    end
  end

end
