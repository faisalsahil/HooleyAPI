ActionMailer::Base.smtp_settings = {
    address: 'smtp.sendgrid.net',
    port: 25,
    domain: 'appsgenii.com',
    user_name: 'appsgeniidev',
    password: 'App$G3n11D3v',
    authentication: :plain
}