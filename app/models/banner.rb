class Banner < ApplicationRecord
  belongs_to :admin_profile


  def self.banner_list(data)
    begin
      data = data.with_indifferent_access
      banner = Banner.all
      if banner.present?
        resp_data       =  banner_list_response(banner)
        resp_status     = 1
        resp_message    = 'Banner list'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = post.errors.messages
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.banner_list_response(banner)
    banner = banner.as_json(
        only: [:id, :title, :alt_text, :url, :created_at],
    )

    {banner: banner}.as_json
  end

  def self.banner_create(data)
    begin
      data = data.with_indifferent_access
      banner = Banner.new(data[:banner])
      banner.save!
      if banner.save!
        resp_data = banner
        resp_status = 1
        resp_message = 'Banner created'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 1
        resp_message = 'Something went wrong,Please try again...!'
        resp_errors = ''
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

end

# == Schema Information
#
# Table name: banners
#
#  id            :integer          not null, primary key
#  title         :string
#  alt_text      :string
#  url           :string
#  detail        :text
#  path          :string
#  from_date     :datetime
#  to_date       :datetime
#  active        :boolean
#  default_photo :boolean
#  show_at_home  :boolean
#  sequence      :integer
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
