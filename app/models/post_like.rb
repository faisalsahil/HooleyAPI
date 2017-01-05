class PostLike < ApplicationRecord
  include JsonBuilder

  belongs_to :post
  belongs_to :member_profile
  
  validates_uniqueness_of :post_id, scope: :member_profile_id
  @@limit = 10

  def self.liked_by_me(post, profile_id)
    post_like = post.post_likes.where(member_profile_id: profile_id).try(:first)
    if post_like && post_like.like_status
      true
    else
      false
    end
  end

  def self.post_like(data, current_user)
    begin
      data                        = data.with_indifferent_access
      post                        = Post.find_by_id(data[:post][:id])
      post_like                   = PostLike.find_by_post_id_and_member_profile_id(post.id, current_user.profile_id) || post.post_likes.build
      post_like.member_profile_id = current_user.profile_id
      post_like.like_status       = data[:post][:is_like]
      if post_like.save
        resp_data     = post_like_live(post_like)
        post_comments = []
        resp_broadcast_data  = PostComment.posts_comments_response(post_comments, current_user, post)
        resp_status          = 1
        resp_errors          = ''
        data[:post][:is_like] == true || data[:post][:is_like] == 1 ? resp_message = 'liked Successfully' : resp_message = 'disliked Successfully'
      else
        resp_data           = {}
        resp_broadcast_data = ''
        resp_status         = 0
        resp_message        = 'Errors'
      end
      resp_request_id = data[:request_id]
      response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      resp_broadcast  = JsonBuilder.json_builder(resp_broadcast_data, resp_status, resp_message, '', errors: resp_errors, type: "Sync")
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

  def self.post_like_live(post_like)
    post_like = post_like.as_json(
        only: [:id],
        include:{
            member_profile: {
                only: [:id, :photo],
                include:{
                    user:{
                        only:[:id, :first_name, :last_name]
                    }
                }
            },
            post: {
                only: [:id],
                methods: [:likes_count]
            }
        }
    )
  
    {post_like: post_like}.as_json
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

  

  def self.post_likes_response(post_likes_array)
    post_likes =  post_likes_array.as_json(
        only:    [:id, :post_id, :like_status, :created_at, :updated_at],
        include: {
            member_profile: {
                only:    [:id, :photo, :country_id, :is_profile_public, :gender],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            }
        }
    )

    {post_likes: post_likes}.as_json
  end
end

# == Schema Information
#
# Table name: post_likes
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  is_deleted        :boolean          default(FALSE)
#  like_status       :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
