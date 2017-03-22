module Notification

  def self.send_hooly_notification(user, alert, screen, is_save_notification, screen_data = {})
    # begin
      badge       = 1
      
      if is_save_notification
        push_notification             = PushNotification.new
        push_notification.user_id     = user.id
        push_notification.alert       = alert
        push_notification.badge       = badge
        push_notification.screen      = screen
        push_notification.screen_data = screen_data
        push_notification.save
      end
      # user_session = user.user_sessions.first
      if user.present? && user.device_type.present? && user.device_token.present?
        if user.device_type == AppConstants::DEVICE_IOS
          data = {
              screen:     screen,
              screen_data: screen_data,
              user:{
                  id: 1,
                  username: user.username ,
                  profile: {
                      id: user.profile_id,
                      photo: user.profile.photo
                  }
              }
          }
          
          app = RailsPushNotifications::APNSApp.first
          app.notifications.create(
              destinations: [user.device_token],
              data: {
                  aps: {
                      alert: alert,
                      badge: 1,
                      sound: 'default',
                      other: data
                  }
              }
          )
          notification = app.push_notifications
        elsif user.device_type == AppConstants::DEVICE_ANDR
          data = {
              alert: alert,
              badge: badge,
              s:     screen,
              uid:   user.id,
              sdata: screen_data
          }

          app = RailsPushNotifications::GCMApp.first
          app.notifications.create(
              destinations: [user.device_token],
              data:         data
          )
          notification = app.push_notifications
        end
      else
        puts "XX"*20
        puts "Notification not send"
        puts "XX"*20
      end
    # rescue => e
    #   puts e.inspect
    # end
  end
end