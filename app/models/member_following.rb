class MemberFollowing < ApplicationRecord
  include AppConstants
  belongs_to :member_profile
  @@limit = 10
  
  def self.is_friend(member_profile, profile_id)
    member_following = MemberFollowing.where(member_profile_id: profile_id, following_profile_id: member_profile.id, following_status: AppConstants::ACCEPTED, is_deleted: false)
    if member_following.present?
      true
    else
      false
    end
  end

  def self.search_member(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      users    = User.all
      if data[:search_key].present?
        profile_ids = users.where('username LIKE ? OR email LIKE ? OR first_name LIKE ? OR last_name LIKE ?',"%#{data[:search_key]}%", "%#{data[:search_key]}%", "%#{data[:search_key]}%", "%#{data[:search_key]}%").pluck(:profile_id)
      else
        profile_ids = users.pluck(:profile_id)
      end
      if profile_ids.present?
        member_profiles = MemberProfile.where(id: profile_ids)
      
        member_profiles = member_profiles.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_profiles)
      
        resp_data = response_member_profiles(member_profiles, current_user)
      
        resp_status = 1
        resp_message = 'success'
        resp_errors = ''
      else
        resp_data = {}
        resp_status = 1
        resp_message = 'success'
        resp_errors = 'No string match found.'
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.response_member_profiles(member_profiles, current_user)
    member_profiles = member_profiles.to_xml(
        only: [:id, :photo],
        :procs => Proc.new { |options, member_profile|
          options[:builder].tag!('is_following', MemberProfile.is_following(member_profile, current_user))
          options[:builder].tag!('is_follower',  MemberProfile.is_following(member_profile, current_user))
        },
        include: {
            user: {
                only: [:id, :email, :username, :first_name, :last_name]
            }
        }
    )
    Hash.from_xml(member_profiles).as_json
  end
  
  def self.get_followers(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      profile = MemberProfile.find_by_id(data[:member_profile_id])
      # followers
      if data[:search_key].present?
        member_followings = MemberFollowing.where(following_status: AppConstants::ACCEPTED, following_profile_id: profile.id, is_deleted: false) if profile.present?
        profile_ids  =  member_followings.pluck(:member_profile_id)
        users = User.where("lower(first_name) like :q or lower(last_name) like :q or lower(email) like :q or lower(username) like :q", q: "%#{data[:search_key]}%".downcase)
        # users   = User.search_by_title(data[:search_key])
        searched_profile_ids = users.where(profile_id: profile_ids).pluck(:profile_id)
        member_followings = MemberFollowing.where(following_status: AppConstants::ACCEPTED, following_profile_id: profile.id, is_deleted: false, member_profile_id: searched_profile_ids)
      else
        member_followings = MemberFollowing.where(following_status: AppConstants::ACCEPTED, following_profile_id: profile.id, is_deleted: false) if profile.present?
      end
    
      if member_followings.present?
        member_followings = member_followings.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_followings)
        resp_data     = member_followings_response(member_followings, current_user, profile, AppConstants::MEMBER_FOLLOWERS)
        resp_status   = 1
        resp_message  = 'success'
        resp_errors   = ''
      else
        resp_data    = {}
        paging_data  = nil
        resp_status  = 0
        resp_message = 'error'
        resp_errors  = 'No one following you.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.follow_member(data, current_user)
    begin
      data = data.with_indifferent_access
    
      member_profile       = current_user.profile
      member_following     = MemberFollowing.find_by_member_profile_id_and_following_profile_id(member_profile.id, data[:member_following][:following_profile_id])
      following_to_profile = MemberProfile.find(data[:member_following][:following_profile_id])
      is_accepted = false
      if member_following.blank?
        member_following   = member_profile.member_followings.build(data[:member_following])
        if following_to_profile && following_to_profile.is_profile_public
          member_following.following_status = AppConstants::ACCEPTED
          resp_message = 'Following Request Submitted'
          is_accepted  = true
          member_following.save!
          # Make friend in two way
          new_following = MemberFollowing.new
          new_following.member_profile_id    = member_following.following_profile_id
          new_following.following_profile_id = member_following.member_profile_id
          new_following.following_status     = member_following.following_status
          new_following.save!
        else
          resp_message = 'Request sent.'
        end
        resp_status = 1
        resp_errors = ''
      else
        if following_to_profile && following_to_profile.is_profile_public
          member_following.following_status = AppConstants::ACCEPTED
          member_following.is_deleted = false
          member_following.save!

          following_to_profile = MemberFollowing.find_by_member_profile_id_and_following_profile_id(data[:member_following][:following_profile_id], member_profile.id)
          following_to_profile.member_profile_id    = member_following.following_profile_id
          following_to_profile.following_profile_id = member_following.member_profile_id
          following_to_profile.following_status     = member_following.following_status
          following_to_profile.is_deleted           = false
          following_to_profile.save!
        else
          member_following.following_status = AppConstants::PENDING
          member_following.is_deleted = false
          member_following.save!
        end
        resp_message = 'Following Request Submitted.'
        resp_status  = 1
        resp_errors  = ''
      end
      resp_data      = {is_im_following: MemberProfile.is_following(following_to_profile, current_user)}
      resp_request_id = data[:request_id]
      response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      [response, is_accepted, member_following]
    rescue Exception => e
      resp_data      = {}
      resp_status    = 0
      paging_data    = ''
      resp_message   = 'error'
      resp_errors    = e
      resp_request_id = data[:request_id]
      response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      [response, is_accepted]
    end
  end

  def self.get_following_requests(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
    
      profile = current_user.profile
      member_followers  = MemberFollowing.where(following_profile_id: current_user.profile_id, following_status: AppConstants::PENDING, is_deleted: false)
      if member_followers.present?
        member_followers = member_followers.page(page.to_i).per_page(per_page.to_i)
        paging_data = JsonBuilder.get_paging_data(page, per_page, member_followers)
        resp_data       = member_followings_response(member_followers, current_user, profile, AppConstants::MEMBER_FOLLOWERS)
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        paging_data     = nil
        resp_message    = 'error'
        resp_errors     = 'You have no pending request.'
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.unfollow_member(data, current_user)
    begin
      data             =  data.with_indifferent_access
      member_following =  MemberFollowing.find_by_member_profile_id_and_following_profile_id(current_user.profile_id, data[:member_following][:following_profile_id])
      if member_following.present?
        member_following.is_deleted = true
        member_following.save!
        frnd_member_following =  MemberFollowing.find_by_member_profile_id_and_following_profile_id(data[:member_following][:following_profile_id], current_user.profile_id)
        if frnd_member_following.present?
          frnd_member_following.is_deleted = true
          frnd_member_following.save!
        end
        resp_status  = 1
        resp_message = 'Unfollow Successfull.'
        resp_errors  = ''
      else
        resp_status  = 0
        resp_message = 'Errors'
        resp_errors  = 'No Follower Found.'
      end
      following_to_profile = MemberProfile.find_by_id(data[:member_following][:following_profile_id])
      resp_data    = {is_im_following: MemberProfile.is_following(following_to_profile, current_user)}
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.accept_reject_follower(data, current_user)
    begin
      data = data.with_indifferent_access
      member_following = MemberFollowing.find_by_id(data[:member_following][:id])
      member_following.following_status = data[:member_following][:following_status]
      member_following.save!
      if member_following.following_status == AppConstants::ACCEPTED
        new_following = MemberFollowing.new
        new_following.member_profile_id    = member_following.following_profile_id
        new_following.following_profile_id = member_following.member_profile_id
        new_following.following_status     = member_following.following_status
        new_following.save!
      end
      resp_data     = {}
      resp_status   = 1
      resp_message  = 'Invitation' + ' '+ member_following.following_status
      resp_errors   = ''
    rescue Exception => e
      member_following = 0
      resp_data     = {}
      resp_status   = 0
      resp_message  = 'error'
      resp_errors   = e
    end
    resp_request_id   = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    [response, resp_status, member_following]
  end

  def self.get_following_members(data, current_user)
    begin
      data = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
    
      profile   = MemberProfile.find_by_id(data[:member_profile][:id])
      member_followings = profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted: false) if profile.present?
      if data[:member_profile][:search_key].present?
        profile_ids     = member_followings.pluck(:following_profile_id)
        users = User.where("first_name @@ :q or last_name @@ :q or email @@ :q", q: "%#{data[:member_profile][:search_key]}%")
        searched_profile_ids = users.where(profile_id: profile_ids).pluck(:profile_id)
        member_followings = profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted: false, following_profile_id: searched_profile_ids)
      end
      if member_followings.present?
        member_followings = member_followings.page(page.to_i).per_page(per_page.to_i)
        paging_data  = JsonBuilder.get_paging_data(page, per_page, member_followings)
        resp_data    = member_followings_response(member_followings, current_user, profile, AppConstants::MEMBER_FOLLOWINGS)
        resp_status  = 1
        resp_message = 'success'
        resp_errors  = ''
      else
        resp_data    = {}
        resp_status  = 0
        resp_message = 'error'
        resp_errors  = 'You are not following to other.'
        paging_data  = nil
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
  
  def self.member_followings_response(member_followings, current_user, searched_profile,root)
    response = []
    member_followings.each do |member_following|
      if root && root == AppConstants::MEMBER_FOLLOWINGS
        profile = MemberProfile.find_by_id(member_following.following_profile_id)
      else
        profile = member_following.member_profile
      end
      user              = profile.user
      country           = profile.country
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
              contact_address:  profile.contact_address,
              is_im_following:  MemberProfile.is_following(profile, current_user),
              is_my_follower:   MemberProfile.is_follower(profile, current_user),
              country: {
                  id:           country.try(:id),
                  country_name: country.try(:country_name)
              },
              user:{
                  id:           user.id,
                  first_name:   user.first_name,
                  last_name:    user.last_name,
                  email:        user.email
              }
          }
      }
  
    end
    profile = {
        id:               searched_profile.id,
        photo:            searched_profile.photo,
        gender:           searched_profile.gender,
        dob:              searched_profile.dob,
        is_im_following:  MemberProfile.is_following(searched_profile, current_user),
        is_my_follower:   MemberProfile.is_follower(searched_profile, current_user),
        country: {
            id:           searched_profile.country.try(:id),
            country_name: searched_profile.country.try(:country_name)
        },
        user:{
            id:            searched_profile.user.id,
            first_name:    searched_profile.user.first_name,
            last_name:     searched_profile.user.last_name,
            email:         searched_profile.user.email
        }
    }
    {"#{root}": response, member_profile: profile}.as_json
  end

  def self.member_following_notification(member_following, current_user, is_accept_reject)
    if is_accept_reject == true
      member_profile      = member_following.member_profile
      approved_by_user = User.find_by_profile_id(member_following.following_profile_id)
      name = approved_by_user.username || "#{approved_by_user.first_name} #{approved_by_user.last_name}" || approved_by_user.email
      
      alert = AppConstants::FRIEND_REQUEST_ACCEPTED + ' ' + name
      screen_data = {member_following_id: member_following.id, status: member_following.following_status, member_profile_id: member_following.following_profile_id}.as_json
      Notification.send_hooly_notification(member_profile.user, alert, AppConstants::FRIEND_REQUEST_SCREEN, true, screen_data)
    else
      name  =  current_user.username || "#{current_user.first_name} #{current_user.last_name}" || current_user.email
      # following_to_profile  = MemberProfile.find(member_following.following_profile_id)
      user = User.find_by_profile_id(member_following.following_profile_id)
      if member_following.following_status == AppConstants::ACCEPTED
        alert  = name + ' ' + AppConstants::START_FOLLOWING_YOU
      else
        alert  = name + ' ' + AppConstants::FRIEND_REQUEST
      end
      screen_data = {member_following_id: member_following.id, status: member_following.following_status, member_profile_id: member_following.member_profile_id}.as_json
      Notification.send_hooly_notification(user, alert, AppConstants::FOLLOWING_SCREEN, true, screen_data)
    end
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
