class PostComment < ApplicationRecord
  include JsonBuilder
  
  belongs_to :post
  belongs_to :member_profile
  
  validates_presence_of :post_comment, presence: true
  
  @@limit = 10
  

  def self.post_comment(data, current_user)
    begin
      data                           = data.with_indifferent_access
      post                           = Post.find_by_id(data[:post][:id])
      post_comment                   = post.post_comments.build(data[:post][:post_comment])
      post_comment.member_profile_id = current_user.profile.id
      if post_comment.save
        resp_status     = 1
        resp_request_id = data[:request_id]
        resp_message    = 'Comment Successfully Posted'
        resp_errors     = ''
        post_comments   = PostComment.where(id: post_comment.id)
        resp_data       =  posts_comments_response(post_comments, current_user, post)
      else
        resp_data       = []
        resp_request_id = data[:request_id]
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'comment failed'
      end

      if resp_status == 1
        response           = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        resp_status        = 1
        resp_message       = 'New Comment Posted'
        resp_request_id    = ''
        resp_errors        = ''
        broadcast_response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")

        [response, broadcast_response]
      else
        response           = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        [response, false]
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id   = data[:request_id]
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end

  def self.post_comments_list(data, current_user, sync=nil)
    begin
      data = data.with_indifferent_access
      max_comment_date = data[:max_comment_date] || Time.now
      min_comment_date = data[:min_comment_date] || Time.now

      post          = Post.find_by_id(data[:post][:id])
      post_comments = post.post_comments.where(is_deleted: false) if post.present?
      if post_comments

        if data[:max_comment_date].present?
          post_comments = post_comments.where("created_at > ?", max_comment_date)
        elsif data[:min_comment_date].present?
          post_comments = post_comments.where("created_at < ?", min_comment_date)
        end

        post_comments = post_comments.order("created_at DESC")
        post_comments = post_comments.limit(@@limit)

        if post_comments.present?
          PostComment.where("created_at > ? AND post_id = ?", post_comments.first.updated_at, post.id).present? ? previous_page_exist = true : previous_page_exist = false
          PostComment.where("created_at < ? AND post_id = ?", post_comments.last.updated_at, post.id).present? ? next_page_exist = true : next_page_exist = false
        end

        resp_data       = posts_comments_response(post_comments, current_user, post)
        resp_status     = 1
        resp_message    = 'Post Comments List'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        paging_data     = ''
        resp_message    = 'Errors'
        resp_errors     = 'Post Comments Does not exist'
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

  def self.delete_post_comment(data, current_user)
    begin
      data         = data.with_indifferent_access
      profile      = current_user.profile
      post_comment = PostComment.find_by_id(data[:post_comment][:id])

      if post_comment.member_profile == profile || post_comment.post.member_profile == profile
        post_comment.is_deleted = true
        post_comment.save!
        resp_status     = 1
        resp_message    = 'Comment Successfully deleted'
        resp_errors     = ''
        resp_data       = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'You are not authorized to destroy this comment.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.report_post(data, current_user)
    begin
      data = data.with_indifferent_access
      post        = Post.find_by_id(data[:post][:id])
      report_post = post.report_posts.build(data[:post][:report_post])
      report_post.save!
      resp_status     = 1
      resp_message    = 'Post Successfully reported.'
      resp_errors     = ''
      resp_data       = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.report_post_comment(data, current_user)
    begin
      data = data.with_indifferent_access

      post_comment        = PostComment.find_by_id(data[:post_comment][:id])
      report_post_comment = post_comment.report_comments.build(data[:post_comment][:report_post_comment])
      report_post_comment.save!

      resp_status     = 1
      resp_message    = 'Post comment successfully reported.'
      resp_errors     = ''
      resp_data       = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  # called from controller
  def self.post_comment_response(post_comment)
    post_comment = post_comment.as_json(
        only:    [:id, :post_comment, :is_deleted, :created_at, :updated_at],
        include: {
            member_profile: {
                only:    [:id, :photo],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            },
            post:           {
                only: [:id]
            }
        }
    )

    { post_comment: post_comment }.as_json
  end

  def self.posts_comments_response(post_comments_array, current_user, post)
    post_comments = post_comments_array.as_json(
        only:    [:id, :post_id, :post_comment, :created_at, :updated_at],
        include: {
            member_profile: {
                only:    [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            }
        }
    )

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
    { post_comments: post_comments, post: post }.as_json
  end
end

# == Schema Information
#
# Table name: post_comments
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  post_comment      :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_deleted        :boolean          default(FALSE)
#
