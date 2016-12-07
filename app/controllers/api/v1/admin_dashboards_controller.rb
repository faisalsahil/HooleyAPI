class Api::V1::AdminDashboardsController < Api::V1::ApiProtectedController

  def index
    member_profiles = MemberProfile.group("DATE(created_at)").count
    # member_profiles = MemberProfile.group("YEAR(created_at)").count
    member_groups   = MemberGroup.group("DATE(created_at)").count
    posts           = Post.group("DATE(created_at)").count
    post_comments   = PostComment.group("DATE(created_at)").count
    resp_data       = response_dashboard_index(member_profiles, member_groups, posts, post_comments)
    resp_status     = 1
    resp_message    = 'Success'
    resp_errors     = ''


    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end


  def response_dashboard_index(member_profiles, member_groups, posts, post_comments)
    data = {
        profiles: member_profiles,
        groups:   member_groups,
        posts:    posts,
        comments: post_comments
    }

  end
end
