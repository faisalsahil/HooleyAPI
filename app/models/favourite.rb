class Favourite < ApplicationRecord
  
  belongs_to :member_profile
  belongs_to :post
  @@limit = 10
  
  
  def self.add_to_favourite(data, current_user)
    begin
      data = data.with_indifferent_access
      member_profile = current_user.profile
        member_profile.favourites.build(data[:favourites_attributes])
      if member_profile.save
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'Favourite not added. something went wrong.'
        resp_errors     = ''
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
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      
      member_profile = current_user.profile
      post_ids = member_profile.favourites.pluck(:post_id)
      posts    = Post.where(id: post_ids)
      posts        = posts.page(page.to_i).per_page(per_page.to_i)
      paging_data  =  JsonBuilder.get_paging_data(page, per_page, posts)
      resp_data    =  Post.posts_array_response(posts, current_user.profile)
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      paging_data     = ''
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
end
