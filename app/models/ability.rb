class Ability
  # include CanCan::Ability
  #
  # def initialize(user)
  #   unless user.nil?
  #     user.admin?
  #     admin user
  #   end
  # end
  #
  #
  # def admin(user)
  #   can [:update, :verify_email,
  #        :change_email,
  #        :change_username,
  #        :change_password,
  #        :destroy], User, id: user.id
  #   can [:show, :update], AdminProfile, id: user.profile_id
  #   can [:index], :admin_dashboards
  #   can [:member_profile], MemberProfiles
  #   can [:get_users_list], Users
  #   can [:get_user_posts], Posts
  #
  # end
end