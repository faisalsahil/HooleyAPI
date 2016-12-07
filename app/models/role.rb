class Role < ApplicationRecord
  has_many :member_profiles

  def self.get_roles(data=nil)
    data  = data.with_indifferent_access
    roles = Role.all
    resp_data = response_roles_list(roles)

    resp_status     = 1
    resp_request_id = data[:request_id] if data.present? && data[:request_id].present?
    resp_message    = 'Roles'
    resp_errors     = ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.response_roles_list(roles)
    roles = roles.as_json(
        only: [:id, :name]
    )

    {roles: roles}.as_json
  end
end

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
