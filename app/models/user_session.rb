class UserSession < ApplicationRecord
  belongs_to :user
  # validates_presence_of :device_type, :device_uuid, presence: true

  private
  def self.authenticate_session(token, request_id)
    user_session = UserSession.find_by_auth_token_and_session_status(token, 'open')
    # user_session = UserSession.find_by_auth_token(token)
    unless user_session
      resp_status     = 0
      resp_request_id = request_id
      resp_message    = 'Error'
      resp_errors     = 'User token is expired or does not exist'
      resp_data       = ''
      response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      [false, response]
    else
      [true, user_session]
    end
  end
end

# == Schema Information
#
# Table name: user_sessions
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  device_type    :string
#  device_uuid    :string
#  auth_token     :string
#  session_status :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  device_token   :string
#
