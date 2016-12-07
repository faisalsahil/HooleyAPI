if AdminProfile.all.blank?
  admin_profile = AdminProfile.create!(phone: "1122334455", about: "I'm admin", state: "Atlanta")

  user                       = admin_profile.build_user
  user.username              = "admin"
  user.email                 = "admin@gmail.com"
  user.password              = "admin1234"
  user.password_confirmation = "admin1234"
  user.save!
end


