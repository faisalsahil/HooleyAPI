class Like < ApplicationRecord
  include JsonBuilder
  
  # belongs_to :post, :counter_cache => true
  belongs_to :likable, polymorphic: true
  belongs_to :member_profile
  
  @@limit = 10
  
  def self.liked_by_me(post, profile_id)
    post_like = post.likes.where(member_profile_id: profile_id).try(:first)
    if post_like && post_like.is_like
      true
    else
      false
    end
  end
  
  def self.like(data, current_user)
    begin
      data                        = data.with_indifferent_access
      post                        = Post.find_by_id(data[:post][:id])
      post_like                   = Like.find_by_likable_id_and_member_profile_id(post.id, current_user.profile_id) || post.likes.build
      post_like.member_profile_id = current_user.profile_id
      post_like.is_like           = data[:post][:is_like]
      if post_like.save
        resp_data       = like_response(post_like)
        post_comments   = []
        resp_broadcast  = Comment.comments_response(post_comments, current_user, post)
        resp_status     = 1
        resp_errors     = ''
        data[:post][:is_like] == true || data[:post][:is_like] == 1 ? resp_message = AppConstants::LIKED : resp_message = AppConstants::DISLIKED
      else
        resp_data       = {}
        resp_broadcast  = ''
        resp_status     = 0
        resp_message    = 'Errors'
      end
      resp_request_id = data[:request_id]
      response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      [response, resp_broadcast]
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id: resp_request_id, errors: resp_errors)
    end
  end
  
  def self.like_response(like)
    like = like.as_json(
        only: [:id, :likable_id, :likable_type],
        include:{
            member_profile: {
                only: [:id, :photo],
                include:{
                    user:{
                        only:[:id, :first_name, :last_name]
                    }
                }
            },
            likable: {
                only: [:id],
                methods: [:likes_count]
            }
        }
    )
    
    {like: like}.as_json
  end

  def self.broadcast_like(response, object_id,  object_type)
    begin
      resp_message    = AppConstants::LIKED
      resp_request_id = ''
      resp_status     = 1
      resp_errors     = ''
      if object_type == AppConstants::POST
        open_sessions = OpenSession.where(media_id: object_id, media_type: AppConstants::POST)
        open_sessions.each do |open_session|
          broadcast_response = response.merge!(session_id: open_session.session_id)
          broadcast_response = JsonBuilder.json_builder(broadcast_response, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
          PostJob.perform_later broadcast_response, open_session.user_id
        end
      else
        open_sessions = OpenSession.where(media_id: object_id, media_type: AppConstants::EVENT)
        open_sessions.each do |open_session|
          broadcast_response = response.merge!(session_id: open_session.session_id)
          broadcast_response = JsonBuilder.json_builder(broadcast_response, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
          EventJob.perform_later broadcast_response, open_session.user_id
        end
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end

  def self.likes_response(likes_array)
    likes =  likes_array.as_json(
        only: [:id, :likable_id, :likable_type],
        include:{
            member_profile: {
                only: [:id, :photo],
                include:{
                    user:{
                        only:[:id, :first_name, :last_name]
                    }
                }
            },
            likable: {
                only: [:id],
                methods: [:likes_count]
            }
        }
    )
  
    {likes: likes}.as_json
  end

  def self.like_notification(object_id, object_type, current_user)
    begin
      profile_ids = []
      if object_type == 'Post'
        objects = Post.where(id: object_id).includes(:post_members, :comments, :likes)
        profile_ids << objects.first.post_members.pluck(:member_profile_id)
      elsif object_type == 'Event'
        objects = Event.where(id: object_id).includes(:event_members, :event_co_hosts, :comments, :likes)
        profile_ids << objects.first.event_members.pluck(:member_profile_id)
        profile_ids << objects.first.event_co_hosts.pluck(:member_profile_id)
      end
      profile_ids << objects.first.comments.pluck(:member_profile_id)
      profile_ids << objects.first.likes.pluck(:member_profile_id)
      profile_ids << objects.first.member_profile_id
      
      users  = User.where(profile_id: profile_ids.flatten.uniq)
      ## ======================== Send Notification ========================
      users && users.each do |user|
        if user != current_user
          if user.profile_id == objects.first.member_profile_id
            message = AppConstants::LIKE
          else
            message = AppConstants::LIKE_OTHER
          end
          name = current_user.username || "#{current_user.first_name} #{current_user.last_name}" || current_user.email
          alert = name + ' ' + message
          if object_type == 'Post'
            screen_data = {post_id: objects.first.id}.as_json
            Notification.send_hooly_notification(user, alert, AppConstants::POST, true, screen_data)
          elsif object_type == 'Event'
            screen_data = {event_id: objects.first.id}.as_json
            Notification.send_hooly_notification(user, alert, AppConstants::EVENT, true, screen_data)
          end
        end
      end
        ## ===================================================================
    rescue Exception => e
      puts e
    end
  end

  
  
  
  
  
  
  def self.post_likes_list(data, current_user, sync=nil)
    begin
      data       = data.with_indifferent_access
      per_page   = (data[:per_page] || @@limit).to_i
      page       = (data[:page] || 1).to_i
      post       = Post.find_by_id(data[:post][:id])
      post_likes = post.post_likes.where(is_deleted: false, like_status: true)
      
      if post_likes
        post_likes  = post_likes.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, post_likes)
        if sync.present?
          resp_data       = post.post_response
        else
          resp_data       = post_likes_response(post_likes)
        end
        
        resp_status     = 1
        resp_message    = 'Post Likes List'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'Post Likes Does not exist'
      end
      resp_request_id = data[:request_id]
      if sync.present?
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync", paging_data: paging_data)
      else
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id   = data[:request_id]
      response          = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end
end
