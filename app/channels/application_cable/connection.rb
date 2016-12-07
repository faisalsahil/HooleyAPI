module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    protected
    def find_verified_user
      if cookies[:auth_token].blank?
        user_session = UserSession.last
      else
        user_session = UserSession.find_by_auth_token(cookies[:auth_token])
      end

      if user_session.present?
        user_session.user
      else
        reject_unauthorized_connection
      end
    end
  end
end