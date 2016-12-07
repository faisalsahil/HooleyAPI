module Profile
  include AppConstants

  def admin?
    self.profile_type == ADMIN
  end
end
