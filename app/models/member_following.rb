class MemberFollowing < ApplicationRecord
  include AppConstants
  belongs_to :member_profile
  @@limit = 10

  def self.search_member(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      profile_ids = User.where('username LIKE ? OR full_name LIKE ? OR email LIKE ?', "%#{data[:member_following][:search_keyword]}%", "%#{data[:member_following][:search_keyword]}%", "%#{data[:member_following][:search_keyword]}%").pluck(:profile_id)
      if profile_ids.present?
        member_profiles = MemberProfile.where(id: profile_ids)

        member_profiles = member_profiles.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_profiles)

        resp_data = response_member_profiles(member_profiles)

        resp_status = 1
        resp_message = 'success'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = 'No string match found.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.follow_member(data, current_user)
    begin
      data = data.with_indifferent_access

      member_profile       = current_user.profile
      member_following     = MemberFollowing.find_by_member_profile_id_and_following_profile_id(member_profile.id, data[:member_following][:following_profile_id])
      following_to_profile = MemberProfile.find(data[:member_following][:following_profile_id])
      
      if member_following.blank?
        member_following   = member_profile.member_followings.build(data[:member_following])
        if following_to_profile && following_to_profile.is_profile_public
          member_following.following_status = AppConstants::ACCEPTED
          resp_message = 'Following Request Submitted'
        else
          send_notification(data[:member_following][:following_profile_id])
          resp_message = 'Request sent.'
        end
        member_following.save!
        resp_status = 1
        resp_errors = ''
      else
        member_following.following_status = AppConstants::PENDING
        member_following.is_deleted = false
        member_following.save!
        resp_message = 'Following Request Submitted.'
        resp_status  = 1
        resp_errors  = ''
      end
      
      resp_data      = {is_im_following: MemberProfile.is_following(following_to_profile, current_user)}
    rescue Exception => e
      resp_data      = ''
      resp_status    = 0
      paging_data    = ''
      resp_message   = 'error'
      resp_errors    = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.unfollow_member(data, current_user)
    begin
      data             =  data.with_indifferent_access
      # profile          =  current_user.profile
      member_following =  MemberFollowing.find_by_member_profile_id_and_following_profile_id(current_user.profile_id, data[:member_following][:following_profile_id])
      if member_following.present?
        member_following.is_deleted = true
        member_following.save!
        resp_status = 1
        resp_message = 'Unfollow Successfull.'
        resp_errors = ''
      else
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = 'No Follower Found.'
      end
      following_to_profile = MemberProfile.find_by_id(data[:member_following][:following_profile_id])
      resp_data    = {is_im_following: MemberProfile.is_following(following_to_profile, current_user)}
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.accept_follower(data, current_user)
    begin
      data = data.with_indifferent_access

      member_following = MemberFollowing.find_by_id(data[:member_following][:id])
      member_following.following_status = data[:member_following][:following_status]
      member_following.save!

      #  Send notification to follower
      member_profile = member_following.member_profile
      follower_to_user_session = member_profile.user.user_sessions.last
      if follower_to_user_session.present?
        # broadcast to follower
        resp_data = ''
        resp_status = 1
        resp_message = "Invitation accepted by #{follower_to_user_session.user.username}."
        resp_errors = ''
        response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, errors: resp_errors)
        ActionCable.server.broadcast "profile_channel_#{follower_to_user_session.auth_token}", response
      end
      resp_data = ''
      resp_status = 0
      resp_message = 'Invitation accepted.'
      resp_errors = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, errors: resp_errors)
  end

  def self.reject_follower(data, current_user)
    begin
      data = data.with_indifferent_access

      member_following = MemberFollowing.find(data[:member_following][:id])
      member_following.following_status = data[:following_status]
      member_following.save!
      resp_data = ''
      resp_status = 1
      resp_message = 'Invitation rejected.'
      resp_errors = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.get_following_requests(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      profile = current_user.profile
      # member_followings  = profile.member_followings.where(following_status: AppConstants::PENDING)
      member_followers  = MemberFollowing.where(following_profile_id: current_user.profile_id, following_status: AppConstants::PENDING, is_deleted: false)

      if member_followers.present?
        member_followers = member_followers.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_followers)

        resp_data       = member_followings_response(member_followers, current_user, profile, AppConstants::MEMBER_FOLLOWERS, true)
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = []
        resp_status     = 0
        paging_data     = nil
        resp_message    = 'error'
        resp_errors     = 'You have not pending request.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  # ok
  def self.get_following_members(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      profile   = MemberProfile.find_by_id(data[:member_profile][:id])
      member_followings = profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted: false) if profile.present?
      if data[:member_profile][:search_key].present?
        profile_ids     = member_followings.pluck(:following_profile_id)
        # member_profiles = MemberProfile.where(id: profile_ids)
        users = User.where("username @@ :q or full_name @@ :q or email @@ :q", q: "%#{data[:member_profile][:search_key]}%")
        searched_profile_ids = users.where(profile_id: profile_ids).pluck(:profile_id)
        member_followings = profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted: false, following_profile_id: searched_profile_ids)
      end
      if member_followings.present?
        member_followings = member_followings.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_followings)
        resp_data = member_followings_response(member_followings, current_user, profile, AppConstants::MEMBER_FOLLOWINGS, true)
        resp_status = 1
        resp_message = 'success'
        resp_errors = ''
      else
        resp_data = []
        resp_status = 0
        resp_message = 'error'
        resp_errors = 'You are not following to other.'
        paging_data = nil
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  # ok
  def self.get_followers(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      profile = MemberProfile.find_by_id(data[:member_profile][:id])
      member_followings = MemberFollowing.where(following_status: AppConstants::ACCEPTED, following_profile_id: profile.id, is_deleted: false) if profile.present?
      if data[:member_profile][:search_key].present?
        profile_ids     = member_followings.pluck(:member_profile_id)
        # member_profiles = MemberProfile.where(id: profile_ids)
        users = User.where("first_name @@ :q or last_name @@ :q or email @@ :q", q: "%#{data[:member_profile][:search_key]}%")
        searched_profile_ids = users.where(profile_id: profile_ids).pluck(:profile_id)
        member_followings = MemberFollowing.where(following_status: AppConstants::ACCEPTED, following_profile_id: profile.id, is_deleted: false, member_profile_id: searched_profile_ids)
      end
      if member_followings.present?
        member_followings = member_followings.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_followings)

        resp_data     = member_followings_response(member_followings, current_user, profile, AppConstants::MEMBER_FOLLOWERS, true)
        resp_status   = 1
        resp_message  = 'success'
        resp_errors   = ''
      else
        resp_data = []
        paging_data = nil
        resp_status = 0
        resp_message = 'error'
        resp_errors = 'No one following you.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.response_member_profiles(member_profiles)
    # ActiveRecord::Base.include_root_in_json = true
    member_profiles = member_profiles.as_json(
        {
            only: [:id, :about, :phone, :photo, :country_id, :gender, :dob],
            include: {
                user: {
                    only: [:id, :first_name, :last_name],
                    include: {
                        role: {
                            only: [:id, :name]
                        }
                    }
                }
            }
        }
    )

    {member_profiles: member_profiles}.as_json

  end

  def self.member_followings_response(member_followings, current_user, searched_profile,root, root_status=nil)
    response = []
    member_followings.each do |member_following|
       if root && root == AppConstants::MEMBER_FOLLOWINGS
        profile = MemberProfile.find_by_id(member_following.following_profile_id)
       else
         profile = member_following.member_profile
       end
       user              = profile.user
       country           = profile.country
       # member_following =  MemberFollowing.where(following_status: ACCEPTED, member_profile_id: current_user.profile.id, following_profile_id: profile.id)
       is_current_user_following =  MemberFollowing.find_by_member_profile_id_and_following_profile_id_and_following_status_and_is_deleted(current_user.profile_id, profile.id, AppConstants::ACCEPTED,false)
       is_current_user_follower  =  MemberFollowing.find_by_member_profile_id_and_following_profile_id_and_following_status_and_is_deleted(profile.id, current_user.profile_id, AppConstants::ACCEPTED,false)

       response << {
           id:                   member_following.id,
           member_profile_id:    member_following.member_profile_id,
           following_profile_id: member_following.following_profile_id,
           following_status:     member_following.following_status,
           created_at:           member_following.created_at,
           updated_at:           member_following.updated_at,
           member_profile:{
               id:               profile.id,
               photo:            profile.photo,
               gender:           profile.gender,
               dob:              profile.dob,
               is_im_following:  is_current_user_following ? true : false,
               is_my_follower:   is_current_user_follower  ? true : false,
               country: {
                   id:           country.try(:id),
                   country_name: country.try(:country_name)
               },
               user:{
                   id:           user.id,
                   first_name:   user.first_name,
                   last_name:    user.last_name,
                   email:        user.email,
                   role: {
                       id:     user.role_id,
                       name:   user.role.name
                   }
               }
           }
       }

    end
    is_current_user_following =  MemberFollowing.find_by_member_profile_id_and_following_profile_id_and_following_status_and_is_deleted(current_user.profile.id, searched_profile.id, ACCEPTED,false)
    is_current_user_follower  =  MemberFollowing.find_by_member_profile_id_and_following_profile_id_and_following_status_and_is_deleted(searched_profile.id, current_user.profile.id, ACCEPTED,false)
    profile = {
      id:               searched_profile.id,
      photo:            searched_profile.photo,
      gender:           searched_profile.gender,
      dob:              searched_profile.dob,
      is_im_following:  is_current_user_following ? true : false,
      is_my_follower:   is_current_user_follower  ? true : false,
      country: {
          id:           searched_profile.country.try(:id),
          country_name: searched_profile.country.try(:country_name)
      },
      user:{
          id:            searched_profile.user.id,
          first_name:    searched_profile.user.first_name,
          last_name:     searched_profile.user.last_name,
          email:         searched_profile.user.email,
          role: {
              id:     searched_profile.user.role_id,
              name:   searched_profile.user.role.name
          }
      }
    }
    if root_status.present?
      {"#{root}": response, member_profile: profile}.as_json
    else
      response
    end
  end
  
  def self.send_notification(data)
    user_to_following = MemberProfile.find(data).user
    if user_to_following.user_sessions.where(session_status: 'open').present?
      # user_session_to_following = user_to_following.user_sessions.last
      resp_data = ''
      resp_request_id = ''
      resp_status = 1
      resp_message = "You have new invitation."
      resp_errors = ''
      response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      ActionCable.server.broadcast "profile_channel_#{user_to_following.id}", response
    end
  end

  # Called from controller
  def self.get_followers_pending_requests(data, current_user)
    data = data.with_indifferent_access
    per_page = (data[:per_page] || @@limit).to_i
    page     = (data[:page] || 1).to_i

    profile = current_user.profile

    member_followings  = MemberFollowing.where(following_profile_id: profile.id, following_status: AppConstants::PENDING)
    # member_followings  = profile.member_followings.where(following_status: PENDING)

    if member_followings.present?
      member_followings = member_followings.page(page.to_i).per_page(per_page.to_i)
      paging_data       = JsonBuilder.get_paging_data(page, per_page, member_followings)

      resp_data       = member_followings_response(member_followings, current_user, profile, AppConstants::MEMBER_FOLLOWINGS, true)
      resp_status     = 1
      resp_message    = 'success'
      resp_errors     = ''
    else
      resp_data       = []
      resp_status     = 0
      paging_data     = nil
      resp_message    = 'error'
      resp_errors     = 'You have not pending request.'
    end

    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
end

# == Schema Information
#
# Table name: member_followings
#
#  id                   :integer          not null, primary key
#  member_profile_id    :integer
#  following_profile_id :integer
#  following_status     :string           default("pending")
#  is_deleted           :boolean          default(FALSE)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
