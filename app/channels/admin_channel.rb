# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class AdminChannel < ApplicationCable::Channel
  def subscribed
    if current_user.present?
      stream_from "admin_channel_#{current_user.id}"
    elsif params[:auth_token].present?
      current_user = find_verified_user
      stream_from "admin_channel_#{current_user.id}"
    else
      reject_unauthorized_connection
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def self.admin_dashboard_index(data, current_user)
    response, user_ids =AdminProfile.admin_dashboard_index(data, current_user)
    AdminJob.perform_later response, user_ids
  end

  protected
  def find_verified_user
    user_session = UserSession.find_by_auth_token(params[:auth_token])

    if user_session.present?
      user_session.user
    else
      reject_unauthorized_connection
    end
  end

end
