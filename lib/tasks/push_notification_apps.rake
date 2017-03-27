task :push_apps => :environment do
  app = RailsPushNotifications::APNSApp.first
  if app.blank?
    puts ":::::::::::::::::::::::: ADDING NEW APNSApp App :::::::::::::::::::::::::::::::::::::::::"
    app                = RailsPushNotifications::APNSApp.new
    app.apns_dev_cert  = File.read(ENV['HOOLEY_APNS_PEM_PATH_' + ENV['HOOLEY_MODE']])
    app.apns_prod_cert = File.read(ENV['HOOLEY_APNS_PEM_PATH_' + ENV['HOOLEY_MODE']])
    app.sandbox_mode   = true
    app.save
  else
    puts ":::::::::::::::::::::::: UPDATING NEW APNSApp MEMBER :::::::::::::::::::::::::::::::::::::::::"
    app.apns_dev_cert  = File.read(ENV['HOOLEY_APNS_PEM_PATH_' + ENV['HOOLEY_MODE']])
    app.apns_prod_cert = File.read(ENV['HOOLEY_APNS_PEM_PATH_' + ENV['HOOLEY_MODE']])
    app.sandbox_mode   = true
    app.save
  end
  
  
  app_gcm = RailsPushNotifications::GCMApp.first
  if app_gcm.blank?
    puts ":::::::::::::::::::::::: ADDING NEW GCMApp MEMBER :::::::::::::::::::::::::::::::::::::::::"
    app_gcm          = RailsPushNotifications::GCMApp.new
    app_gcm.gcm_key  = ENV['HOOLEY_GCM_KEY_' + ENV['HOOLEY_MODE']]
    app.save
  else
    puts ":::::::::::::::::::::::: UPDATING NEW GCMApp MEMBER :::::::::::::::::::::::::::::::::::::::::"
    app.gcm_key  = ENV['HOOLEY_GCM_KEY_' + ENV['HOOLEY_MODE']]
    app.save
  end
end