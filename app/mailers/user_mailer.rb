class UserMailer < ApplicationMailer
  def registration_confirmation(email)
    @email = email
    @token = User.find_by_email(email).authentication_token
    mail(to: email, subject: "Confirmation Email", from: "uashraf391@gmail.com")
  end
end
