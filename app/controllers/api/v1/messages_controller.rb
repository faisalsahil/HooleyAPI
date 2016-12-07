class Api::V1::MessagesController < Api::V1::ApiProtectedController

  def index
    messages = Message.where(reciever_id: params[:id])

    if messages.present?
      resp_data = messages
      resp_status = 1
      resp_message = 'Message List'
      resp_errors = ''
    else
      resp_data = ''
      resp_status = 0
      resp_message = 'Errors'
      resp_errors = 'message not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end


  def sent_messages
    messages = Message.where(sender_id: params[:id])

    if messages.present?
      resp_data = messages
      resp_status = 1
      resp_message = 'Message List'
      resp_errors = ''
    else
      resp_data = ''
      resp_status = 0
      resp_message = 'Errors'
      resp_errors = 'message not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)

  end


  def show
    message = Message.find_by_id(params[:id])
    if message.present?
      message = message.as_json(
          only: [:id,:sender_id, :reciever_id,:content, :subject, :created_at]

      )

      resp_data    = message

      render json: resp_data
    end
  end


  def destroy
    message = Message.find_by_id(params[:id])
    if message.present?
      message.destroy
      resp_data    = ''
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def create

    current_user = User.find_by_id(params[:sender_id])
    resp_data = Message.create_message(params, current_user)
    render json: resp_data
  end

  def show_inbox
    current_user = User.find_by_id(params[:id])
    resp_data = Message.show_inbox(params, current_user)
    render json: resp_data
  end

end
