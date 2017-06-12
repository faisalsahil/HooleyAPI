class ReportPost < ApplicationRecord
  belongs_to :member_profile
  belongs_to :post
  
  validates_uniqueness_of :member_profile_id, :scope => :post_id
  
  def self.report_a_post(data, current_user)
    begin
      report_post = ReportPost.find_by_member_profile_id_and_post_id(data[:post_id], current_user.profile_id) || current_user.profile.report_posts.build
      report_post.post_id = data[:post_id]
      report_post.save if report_post.new_record?
      resp_data       = {}
      resp_status     = 1
      resp_message    = 'success'
      resp_errors     = ''
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
  
  def self.is_reported_by_me(post, profile_id)
    report_post = ReportPost.find_by_member_profile_id_and_post_id(profile_id, post.id)
    if report_post.present?
      true
    else
      false
    end
  end
end
