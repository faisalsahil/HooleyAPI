class Message < ApplicationRecord

  def self.create_message(data, current_user)
    begin
      data    = data.with_indifferent_access
      message = Message.new(data[:message])
      message.sender_id = current_user.id
      if message.save
        resp_status = 1
        resp_message = 'Message Sent'
        resp_errors = ''
      else
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = event.errors.messages
      end
      resp_data = ''
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

  def self.show_inbox(data, current_user)
    begin
      data     = data.with_indifferent_access
      messages = Message.where(reciever_id: current_user.id)

      if messages.present?
        resp_data    = {messages: messages}
        resp_status  = 1
        resp_message = 'Message List'
        resp_errors  = ''
      else
        resp_data    = ''
        resp_status  = 0
        resp_message = 'Errors'
        resp_errors  = 'Message Not Found'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    response          = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
end

# == Schema Information
#
# Table name: messages
#
#  id          :integer          not null, primary key
#  sender_id   :integer
#  reciever_id :integer
#  content     :text
#  subject     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
