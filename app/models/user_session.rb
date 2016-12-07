class UserSession < ApplicationRecord
  belongs_to :user
  # validates_presence_of :device_type, :device_uuid, presence: true


  def self.update_uuid(data, current_user)
    data                     = data.with_indifferent_access
    is_success, user_session = UserSession.authenticate_session(data[:user_session][:token], data[:request_id])
    return user_session unless is_success
    if user_session.device_type == data[:user_session][:device_type]
      user_session.device_uuid = data[:user_session][:new_device_uuid]
      user_session.save!

      resp_status     = 1
      resp_request_id = data[:request_id]
      resp_message    = 'Device id updated.'
      resp_errors     = ''
      resp_data       = user_session.as_json(
          only: [:id, :auth_token, :device_uuid, :device_type]
      )
    else
      resp_status     = 0
      resp_request_id = data[:request_id]
      resp_message    = 'Device type mismatch.'
      resp_errors     = 'Error'
      resp_data       = ''
    end

    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end


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
