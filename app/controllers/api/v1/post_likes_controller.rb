class Api::V1::PostLikesController < Api::V1::ApiProtectedController
  
  def index
    post         =  Post.find_by_id(params[:post_id])
    post_likes   =  post.likes
    post_likes   =  post_likes.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data  = get_paging_data(params[:page], params[:per_page], post_likes)
    resp_data    = PostLike.post_likes_response(post_likes)
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end
end
