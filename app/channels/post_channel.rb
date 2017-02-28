class PostChannel < ApplicationCable::Channel
  
  # after_subscribe :newly_created_posts
  def subscribed
    if params[:post_id].present?
      stream_from "post_#{params[:post_id]}"
      sync_comments(current_user, params[:post_id], params[:session_id],'Post')
    elsif params[:event_id].present?
      stream_from "event_#{params[:event_id]}"
      sync_comments(current_user, params[:event_id], params[:session_id], 'Event')
    elsif current_user.present?
      stream_from "post_channel_#{current_user.id}"
      newly_created_posts(current_user)
    else
      current_user = find_verified_user
      stream_from "post_channel_#{current_user.id}"
    end
  end

  def unsubscribed
    current_user.last_subscription_time = Time.now
    current_user.save!
    if params[:post_id].present?
      open_sessions = OpenSession.where(user_id: current_user.id, media_id: params[:post_id], media_type: AppConstants::POST)
      open_sessions.destroy_all if open_sessions.present?
    elsif params[:event_id].present?
      open_sessions = OpenSession.where(user_id: current_user.id, media_id: params[:event_id], media_type: AppConstants::EVENT)
      open_sessions.destroy_all if open_sessions.present?
    end
    stop_all_streams
  end

  def newly_created_posts(current_user)
    response = Post.newly_created_posts(current_user)
    PostJob.perform_later response, current_user.id if response.present?
  end

  def sync_comments(current_user, object_id, session_id, type)
    if type == AppConstants::POST
      params = {user_id: current_user.id, media_id: object_id, media_type: AppConstants::POST, session_id: session_id}
      open_session = OpenSession.find_by_user_id_and_media_id_and_media_type(current_user.id, object_id, AppConstants::POST) || OpenSession.new(params)
      open_session.save if open_session.new_record?
      data  = { post: { id: object_id } }
    else
      params = {user_id: current_user.id, media_id: object_id, media_type: AppConstants::EVENT, session_id: session_id}
      open_session = OpenSession.find_by_user_id_and_media_id_and_media_type(current_user.id, object_id, AppConstants::EVENT) || OpenSession.new(params)
      open_session.save if open_session.new_record?
      data  = { event: { id: object_id } }
    end
    response = Comment.comments_list(data, current_user, true, session_id)
    PostJob.perform_later response, current_user.id
  end

  def post_create(data)
    response = Post.post_create(data, current_user)
    PostJob.perform_later response, current_user.id
    json_obj = JSON.parse(response)
    post_id  = json_obj["data"]["post"]["id"]
    Post.post_sync(post_id, current_user)
  end

  def post_destroy(data)
    response = Post.post_destroy(data, current_user)
    PostJob.perform_later response, current_user.id
  end

  def post_show(data)
    response = Post.post_show(data, current_user)
    PostJob.perform_later response, current_user.id
  end

  def post_update(data)
    response = Post.post_update(data, current_user)
    PostJob.perform_later response, current_user.id
  end

  def post_list(data)
    response = Post.post_list(data, current_user)
    PostJob.perform_later response, current_user.id
  end

  def sync_akn(data)
    response = Post.sync_ack(data, current_user)
  end

  def comment(data)
    response, broadcast_response = Comment.comment(data, current_user)
    PostJob.perform_later response, current_user.id
    if broadcast_response.present?
      json_obj = JSON.parse(response)
      object_id   = json_obj['data']['comments'][0]['commentable_id']
      object_type = json_obj['data']['comments'][0]['commentable_type']
      Comment.broadcast_comment(broadcast_response, object_id,  object_type)
    end
  end

  def comments_list(data)
    response = Comment.comments_list(data, current_user)
    PostJob.perform_later response, current_user.id
  end

  # def post_like(data)
  #   response, resp_broadcast = Like.like(data, current_user)
  #   PostJob.perform_later response, current_user.id
  #   json_obj = JSON.parse(response)
  #   if json_obj["resp_status"] == AppConstants::LIKED
  #     object_id   = json_obj['data']['like']['likable_id']
  #     object_type = json_obj['data']['like']['likable_type']
  #     Like.broadcast_like(resp_broadcast, object_id,  object_type)
  #   end
  # end

  def like(data)
    response, resp_broadcast = Like.like(data, current_user)
    PostJob.perform_later response, current_user.id
    json_obj = JSON.parse(response)
    binding.pry
    if json_obj["message"] == AppConstants::LIKED
      object_id   = json_obj['data']['like']['likable_id']
      object_type = json_obj['data']['like']['likable_type']
      Like.broadcast_like(resp_broadcast, object_id,  object_type)
    end
  end
  
  # def post_members_list(data, current_user)
  #   response = PostMember.post_members_list(data, current_user)
  #   PostJob.perform_later response, current_user.id
  # end
  #
  # def post_likes_list(data)
  #   response = PostLike.post_likes_list(data, current_user)
  #   PostJob.perform_later response, current_user.id
  # end
  #
  # def auto_complete(data)
  #   response = Hashtag.auto_complete(data, current_user)
  #   PostJob.perform_later response, current_user.id
  # end
  
  protected
  def find_verified_user
    user_session = UserSession.find_by_auth_token(params[:auth_token])

    if user_session.present?
      user_session.user
    else
      reject_unauthorized_connection
    end
  end
end
