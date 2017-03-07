class Category < ApplicationRecord
  
  def self.get_categories(data, current_user)
    categories = Category.all
    categories = categories.as_json(
               only: [:id, :name, :is_deleted]
    )
    resp_data = {categories: categories}.as_json
    resp_status     = 1
    resp_request_id = data[:request_id] if data && data[:request_id].present?
    resp_message    = 'Categories'
    resp_errors     = ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
end
