class Hashtag < ApplicationRecord

  include PgSearch

  pg_search_scope :search_by_title,
    against: :name,
    using: {
        tsearch:{
            any_word: true,
            dictionary: "english"
        }
    }

  def self.auto_complete(data, current_user)
    begin
      data     = data.with_indifferent_access
      if data["key"].present?
        hash_tags = Hashtag.where("lower(name) like ?", "%#{data["key"]}%".downcase).order("count DESC")
      else
        hash_tags = Hashtag.order("count DESC")
      end
      hash_tags = hash_tags.take(5)
      resp_data = {hash_tags: hash_tags}.as_json
      resp_status = 1
      resp_message = 'success'
      resp_errors = ''
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
end

# == Schema Information
#
# Table name: hashtags
#
#  id         :integer          not null, primary key
#  name       :string
#  count      :integer          default(0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
