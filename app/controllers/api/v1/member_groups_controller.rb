class Api::V1::MemberGroupsController < Api::V1::ApiProtectedController

  def user_groups
    profile      = User.find_by_id(params[:user_id]).profile
    resp_data    = user_group_list_response(profile)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def group_details

    group        = MemberGroup.find_by_id(params[:id])
    resp_data    = user_group_details_response(group)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def group_destroy
    user             = User.find_by_id(params[:user_id])
    group            = MemberGroup.find_by_id_and_member_profile_id(params[:id], user.profile.id)
    group.is_deleted = true
    group.save!

    resp_data    = ''
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def user_group_list_response(profile)
    profile.as_json(
        only:    [:id, :about, :phone, :photo, :country_id, :is_profile_public, :state, :default_group_id],
        include: {
            user:          {
                only: [:id, :profile_id, :profile_type, :full_name, :email, :username]
            },
            member_groups: {
                only:    [:id, :group_name],
                methods: [:member_group_contacts_count]
            }
        }
    )
  end

  def user_group_details_response(group)
    group.as_json(
        only:    [:id, :group_name],
        include: {
            member_group_contacts: {
                only:    [:id, :profile_id],
                include: {
                    member_profile: {
                        only:    [:id],
                        include: {
                            user: {
                                only: [:id, :username, :email]
                            }
                        }
                    }
                }
            },
            member_profile:        {
                only:    [:id, :about, :phone],
                include: {
                    user: {
                        only: [:id, :username, :email]
                    }
                }
            }
        }
    )
  end
end
