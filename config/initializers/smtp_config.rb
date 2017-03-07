ActionMailer::Base.smtp_settings = {
    address:   ENV['HOOLEY_SMTP_ADDRESS_' + ENV['HOOLEY_MODE']],
    domain:    ENV['HOOLEY_SMTP_DOMAIN_' + ENV['HOOLEY_MODE']],
    user_name: ENV['HOOLEY_SMTP_USERNAME_' + ENV['HOOLEY_MODE']],
    password:  ENV['HOOLEY_SMTP_PASSWORD_' + ENV['HOOLEY_MODE']],
    :port => 25,
    :authentication => :plain,
    :enable_starttls_auto => true
}