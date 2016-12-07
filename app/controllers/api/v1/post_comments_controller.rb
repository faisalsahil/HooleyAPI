class Api::V1::PostCommentsController < ApplicationController

  def create
    puts "XXXXXX"*90
    puts params.inspect
    puts "XXXXXX"*90
    current_user                 = MemberProfile.find_by_id(params[:member_profile_id]).user
    response, broadcast_resposne = PostComment.post_comment(params, current_user)
    return render json: response
  end

  private
  def set_params
    params.require(:post_comment).permit(:post_comment)
  end

end
