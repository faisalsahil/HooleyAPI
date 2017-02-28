class Comment < ApplicationRecord
  
  belongs_to :commentable, polymorphic: true
  belongs_to :member_profile

  validates_presence_of :comment, presence: true

  @@limit = 3

  def is_co_host_or_host
    profile_id = self.member_profile_id
    if self.commentable_type == 'Event'
      event  = self.commentable
    else
      event  = self.commentable.event
    end
    if event.member_profile_id == profile_id
      return 'host'
    elsif EventCoHost.find_by_event_id_and_member_profile_id(event.id, profile_id).present?
      return 'Cohost'
    else
      return false
    end
  end

  def self.comment(data, current_user)
    begin
      data        = data.with_indifferent_access
      if data[:post].present?
        post      = Post.find_by_id(data[:post][:id])
        comment   = post.comments.build(data[:post][:comment])
      else
        event     = Event.find_by_id(data[:event][:id])
        comment   = event.comments.build(data[:event][:comment])
      end
      comment.member_profile_id = current_user.profile_id
      if comment.save
        comments        =  Comment.where(id: comment.id)
        if data[:post].present?
          resp_data     =  comments_response(comments, current_user, post)
        else
          resp_data     =  comments_response(comments, current_user, nil, event)
        end
        resp_status     = 1
        resp_request_id = data[:request_id]
        resp_message    = 'Comment Successfully Posted'
        resp_errors     = ''
        response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        
        broadcast_response = resp_data
      else
        resp_data       = {}
        resp_request_id = data[:request_id]
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'Comment failed'
        response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        broadcast_response = false
      end
      [response, broadcast_response]
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end

  def self.comments_response(comments, current_user, post=nil, event=nil)
    comments = comments.as_json(
        only:    [:id, :commentable_id, :commentable_type, :comment, :created_at, :updated_at],
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
    if post.present?
      status = PostLike.liked_by_me(post, current_user.profile_id)
      post   = post.as_json(
          only: [:id, :post_title, :post_description, :datetime, :post_datetime, :is_post_public, :created_at, :updated_at, :post_type, :location, :latitude, :longitude],
          methods: [:likes_count, :comments_count, :post_members_counts],
          include: {
              member_profile: {
                  only: [:id, :photo],
                  include: {
                      user: {
                          only: [:id, :first_name, :last_name]
                      }
                  }
              },
              event:{
                  only:[:id, :event_name]
              },
              post_attachments: {
                  only: [:id, :attachment_url, :thumbnail_url, :attachment_type],
                  include:{
                      post_photo_users:{
                          only:[:id, :x_coordinate, :y_coordinate, :member_profile_id, :post_attachment_id],
                          include: {
                              member_profile: {
                                  only: [:id],
                                  include: {
                                      user: {
                                          only: [:id, :first_name, :last_name]
                                      }
                                  }
                              }
                          }
                      }
                  }
              }
          }
      ).merge!(liked_by_me: status)
      { comments: comments, post: post }.as_json
    else
      event = event.as_json(
          only:[:id, :event_name, :member_profile_id, :location, :latitude, :longitude, :radius, :event_details, :is_friends_allowed, :is_public, :is_paid, :category_id, :event_type, :start_date, :end_date, :created_at, :updated_at, :custom_event, :message_from_host],
          include:{
              member_profile:{
                  only: [:id, :photo],
                  include:{
                      user:{
                          only: [:id, :first_name, :last_name, :email]
                      }
                  }
              },
              event_attachments:{
                  only:[:id, :event_id, :attachment_type, :message, :attachment_url, :thumbnail_url, :poster_skin]
              },
              event_co_hosts:{
                  only:[:id, :event_id, :member_profile_id],
                  include:{
                      member_profile: {
                          only: [:id, :photo],
                          include: {
                              user: {
                                  only: [:id, :first_name, :last_name]
                              }
                          }
                      }
                  }
              }
          }
      )
      { comments: comments, event: event }.as_json
    end
  end

  def self.comments_list(data, current_user, sync=nil)
    begin
      data = data.with_indifferent_access
      max_comment_date = data[:max_comment_date] || Time.now
      min_comment_date = data[:min_comment_date] || Time.now
      if data[:post].present?
        post     = Post.find_by_id(data[:post][:id])
        comments = post.comments.where(is_deleted: false)
      else
        event    = Event.find_by_id(data[:event][:id])
        comments = event.comments.where(is_deleted: false)
      end
      
      if comments.present?
        if data[:max_comment_date].present?
          comments = comments.where("created_at > ?", max_comment_date)
        elsif data[:min_comment_date].present?
          comments = comments.where("created_at < ?", min_comment_date)
        end
      
        comments = comments.order("created_at DESC")
        comments = comments.limit(@@limit)
      
        if comments.present?
          Comment.where("created_at > ? AND commentable_id = ? AND commentable_type = ? ", comments.first.updated_at, comments.first.commentable_id, comments.first.commentable_type).present? ? previous_page_exist = true : previous_page_exist = false
          Comment.where("created_at < ? AND commentable_id = ? AND commentable_type = ? ", comments.last.updated_at, comments.first.commentable_id, comments.first.commentable_type).present? ? next_page_exist = true : next_page_exist = false
        end
        
        if data[:post].present?
          resp_data   =  comments_response(comments, current_user, post)
        else
          resp_data   =  comments_response(comments, current_user, nil, event)
        end
        resp_status     = 1
        resp_message    = 'Comments List'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'No comments found'
      end
    
      resp_request_id = data[:request_id]
      if sync.present?
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync", next_page_exist: next_page_exist, previous_page_exist: previous_page_exist, post_list: true)
      else
        JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, next_page_exist: next_page_exist, previous_page_exist: previous_page_exist, post_list: true)
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end
  
  def self.broadcast_comment(response, object_id, object_type)
    begin
      resp_message    = 'New Comment Posted'
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
end
