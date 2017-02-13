class Api::V1::PostCommentsController < Api::V1::ApiProtectedController
  
  # call fom web
  def index
    post            =  Post.find_by_id(params[:post_id])
    post_comments   =  post.post_comments
    post_comments   =  post_comments.page(params[:page].to_i).per_page(params[:per_page].to_i)
    paging_data     =  get_paging_data(params[:page], params[:per_page], post_comments)
    post_comments   =  post_comments.as_json(
        only:    [:id, :post_id, :post_comment, :created_at, :updated_at, :is_deleted],
        methods:[:is_co_host_or_host],
        include: {
            member_profile: {
                only:    [:id, :photo],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            }
        }
    )
    resp_data    = {post_comments: post_comments}.as_json
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors, paging_data)
  end

  # Call from web
  def destroy
    post_comment  =  PostComment.find_by_id(params[:id])
    if post_comment.present?
      if post_comment.is_deleted
        post_comment.is_deleted = false
      else
        post_comment.is_deleted = true
      end
      post_comment.save!
      resp_data    = {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'post not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
end
