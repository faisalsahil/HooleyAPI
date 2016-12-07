class Api::V1::FansController< Api::V1::ApiProtectedController

  def index
    # params = {
    #     member_profile:{
    #         id: 1
    #     }
    # }
    current_user = MemberProfile.find_by_id(params[:member_profile][:id]).user
    get_followers = MemberFollowing.get_followers(params, current_user)
    return render json: get_followers
  end

  def fan_requests
    current_user       = MemberProfile.find_by_id(params[:member_profile][:id]).user
    following_requests = MemberFollowing.get_followers_pending_requests(params, current_user)
    return render json: following_requests
  end

  def accept_fan_request
    current_user       = MemberProfile.find_by_id(params[:member_following][:current_profile_id]).user
    accept_follower = MemberFollowing.accept_follower(params, current_user)
    return render json: accept_follower
  end

  def reject_fan_request
    current_user       = MemberProfile.find_by_id(params[:member_following][:current_profile_id]).user
    accept_follower = MemberFollowing.reject_follower(params, current_user)
    return render json: accept_follower
  end

end
