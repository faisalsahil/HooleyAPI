class Favourite < ApplicationRecord
  
  belongs_to :member_profile
  belongs_to :post
  @@limit = 10
  
  def self.is_my_favourite(post, profile_id)
    favourite = Favourite.find_by_member_profile_id_and_post_id(profile_id, post.id)
    if favourite.present?
      return true
    else
      false
    end
  end
  
  def self.add_to_favourite(data, current_user)
    begin
      data = data.with_indifferent_access
      if not data[:is_favourite].present?
          old_fav = Favourite.find_by_member_profile_id_and_post_id(current_user.profile_id, data[:post_id])
          old_fav.destroy if old_fav.present?
          resp_data       = {}
          resp_errors     = ''
          resp_status     = 1
          resp_message    = 'Deleted successfully'
          resp_errors     = ''
      else
        favourite = Favourite.find_by_member_profile_id_and_post_id(current_user.profile_id, data[:post_id]) || Favourite.new
        favourite.member_profile_id = current_user.profile_id
        favourite.post_id = data[:post_id]
        favourite.save if favourite.new_record?
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.favourites_list(data, current_user)
    begin
      data          = data.with_indifferent_access
      max_post_date = data[:max_post_date] || Time.now
      min_post_date = data[:min_post_date] || Time.now
    
      profile  = MemberProfile.find_by_id(data[:member_profile_id])
      post_ids = profile.favourites.pluck(:post_id)
      posts    = Post.where(id: post_ids)
    
      if data[:max_post_date].present?
        posts = posts.where("created_at > ?", max_post_date)
      elsif data[:min_post_date].present?
        posts = posts.where("created_at < ?", min_post_date)
      end
    
      # if data[:filter_type].present?
      #   post_ids = posts.pluck(:id)
      #   posts = Post.joins(:post_attachments).where(id: post_ids, post_attachments: {attachment_type: data[:filter_type]})
      # end
    
      posts = posts.order("created_at DESC")
      posts = posts.limit(@@limit)
    
      if posts.present?
        Post.where("created_at > ? AND id IN (?)", posts.first.created_at, post_ids).present? ? previous_page_exist = true : previous_page_exist = false
        Post.where("created_at < ? AND id IN (?)", posts.last.created_at,  post_ids).present? ? next_page_exist = true : next_page_exist = false
      end
    
      paging_data  = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      resp_data    = Post.timeline_posts_array_response(posts, profile, current_user)
      resp_status  = 1
      resp_message = 'Favourite list'
      resp_errors  = ''
    rescue Exception => e
      resp_data    = {}
      resp_status  = 0
      paging_data  = ''
      resp_message = 'error'
      resp_errors  = e
    end
    open_session    = OpenSession.find_by_user_id_and_media_type(current_user.id, data[:type]) if data[:type].present?
    if open_session.present?
      resp_data     = resp_data.merge!(session_id: open_session.session_id)
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
end
