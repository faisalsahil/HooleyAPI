class Api::V1::PostsController < Api::V1::ApiProtectedController
  
  # call from web
  def index
    if params[:start_date].present? && params[:end_date].present?
      posts =  Post.where('created_at >= ? AND updated_at <= ?', params[:start_date], params[:end_date]).order('created_at DESC')
    else
      posts = Post.all.order('created_at DESC')
    end
    member_profile = MemberProfile.find_by_id(params[:member_profile_id])
    posts        =  posts.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data  =  get_paging_data(params[:page], params[:per_page], posts)
    resp_data    =  Post.posts_array_response(posts, member_profile)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
  
  # Call from app
  def discover
    # params = {
    #   "auth_token": "111111111",
    #   "per_page":10,
    #   "page":1,
    #   "type": "",
    #   "search_key": "hello"
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      response = Post.discover(params, user_session.user)
      render json: response
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  # Call from web
  def destroy
    post  =  Post.find_by_id_and_event_id(params[:id], params[:event_id])
    if post.present?
      post.is_deleted = params[:is_block]
      post.save!
      resp_data    = {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'Post not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
end
