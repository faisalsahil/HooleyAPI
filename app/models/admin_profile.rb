class AdminProfile < ApplicationRecord
  has_one :user, as: :profile
  accepts_nested_attributes_for :user
  belongs_to :country

  def admin_profile(auth_token)
    member_profile = self.as_json(
        only:    [:id, :about, :phone, :photo, :country_id, :is_profile_public, :state, :default_group_id],
        include: {
            user:    {
                only: [:id, :profile_id, :profile_type, :first_name, :email, :username, :last_name]
            },
            country: {
                only: [:id, :country_name]
            }
        }).merge!(auth_token: auth_token).as_json
    { member_profile: member_profile }.as_json
end
  def response_dashboard_index(member_profiles, member_groups, posts, post_comments)
    data = {
        profiles: member_profiles,
        groups:   member_groups,
        posts:    posts,
        comments: post_comments
    }

  end
  # def admin_dashboard_index(data, current_user)
  #
  #   data     = data.with_indifferent_access
  #   profile  = currnet_user.profile
  #
  #   member_profiles = MemberProfile.group("DATE(created_at)").count
  #   member_groups   = MemberGroup.group("DATE(created_at)").count
  #   posts           = Post.group("DATE(created_at)").count
  #   post_comments   = PostComment.group("DATE(created_at)").count
  #   resp_data       = response_dashboard_index(member_profiles, member_groups, posts, post_comments)
  #   resp_status     = 1
  #   resp_message    = 'Success'
  #   resp_errors     = ''
  #
  #   common_api_response(resp_data, resp_status, resp_message, resp_errors)
  #
  # end
end

# == Schema Information
#
# Table name: admin_profiles
#
#  id         :integer          not null, primary key
#  about      :text
#  phone      :string
#  country_id :integer
#  state      :string
#  photo      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
