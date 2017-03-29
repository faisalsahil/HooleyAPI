class MemberProfile < ApplicationRecord
  include AppConstants
  include PgSearch

  has_one    :user, as: :profile
  has_many   :synchronizations, as: :media
  has_many   :member_followings
  has_many   :posts
  has_many   :events
  has_many   :profile_interests
  has_many   :event_bookmarks
  belongs_to :country
  belongs_to :city
  belongs_to :occupation
  belongs_to :college_major
  belongs_to :relationship_status
  belongs_to :political_view
  belongs_to :religion
  belongs_to :language
  belongs_to :ethnic_background
  
  accepts_nested_attributes_for :user, :profile_interests

  @@limit = 10
  @@current_profile = nil

  acts_as_mappable default_units: :miles, lat_column_name: :latitude, lng_column_name: :longitude
  
  pg_search_scope :search_by_name,
    against: :name,
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }


  def posts_count
    self.posts.count
  end
  
  def events_count
    self.events.count
  end

  def followings_count
    self.member_followings.where(following_status: AppConstants::ACCEPTED).count
  end

  def followers_count
    MemberFollowing.where(following_profile_id: self.id, following_status: AppConstants::ACCEPTED).count
  end

  def self.is_following(profile, current_user)
    member_followings = MemberFollowing.where(member_profile_id: current_user.profile_id, following_profile_id: profile.id, is_deleted: false)
    if member_followings.blank?
      0
    elsif member_followings.present? && member_followings.first.following_status == AppConstants::ACCEPTED
      1
    elsif member_followings.present? && member_followings.first.following_status == AppConstants::PENDING
      2
    elsif member_followings.present? && member_followings.first.following_status == AppConstants::REJECTED
      3
    end
  end

  def self.is_follower(profile, current_user)
    member_followers = MemberFollowing.where(following_status: AppConstants::ACCEPTED, member_profile_id: profile.id, following_profile_id: current_user.profile_id)
    if member_followers.blank?
      0
    elsif member_followers.present? && member_followers.first.following_status == AppConstants::ACCEPTED
      1
    elsif member_followers.present? && member_followers.first.following_status == AppConstants::PENDING
      2
    elsif member_followers.present? && member_followers.first.following_status == AppConstants::REJECTED
      3
    end
  end

  def member_profile(auth_token=nil)
    member_profile = self.as_json(
        only: [:id, :photo, :country_id, :city_id, :is_profile_public, :gender, :dob, :high_school, :is_age_visible, :gender, :current_city, :home_town, :employer, :college, :high_school, :organization, :hobbies, :banner_image, :is_near_me_event_alert, :is_hooly_invite_alert, :is_my_upcoming_event_alert, :is_direct_message_alert, :is_contact_info_shown, :is_social_info_shown, :is_direct_message_allow, :is_private_media_share, :is_public_media_share, :near_event_search],
        methods: [:posts_count, :followings_count, :followers_count],
        include: {
            user: {
                only: [:id, :profile_id, :profile_type, :first_name, :email, :last_name, :phone]
            },
            profile_interests:{
                only:[:id, :name, :interest_type, :photo_url]
            },
            country: {
                only: [:id, :country_name]
            },
            city:{
                only:[:id, :name]
            },
            occupation:{
                only:[:id, :name]
            },
            college_major:{
                only:[:id, :name]
            },
            relationship_status:{
                only:[:id, :name]
            },
            political_view:{
                only:[:id, :name]
            },
            religion:{
                only:[:id, :name]
            },
            language:{
                only:[:id, :name]
            },
            ethnic_background:{
                only:[:id, :name]
            }
        }
    ).merge!(auth_token: auth_token).as_json

    {member_profile: member_profile}.as_json
  end

  def self.sign_up(data)
    data = data.with_indifferent_access
    member_profile = MemberProfile.new
    member_profile.attributes = data[:member_profile]
    if member_profile.save
      resp_status = 1
      resp_message = 'Please check your email and verify your account.'
      resp_errors = ''
    else
      resp_status = 0
      resp_message = 'Errors'
      resp_errors = error_messages(member_profile)
    end
    resp_data = ''
    resp_request_id = data[:request_id] if data && data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.validate_email_and_password(data)
    status = false
    message = ''
    if data[:member_profile][:user_attributes][:email] != data[:member_profile][:user_attributes][:retype_email]
      message = "Email mismatch."
      status = true
    end
    if data[:member_profile][:user_attributes][:password] != data[:member_profile][:user_attributes][:password_confirmation]
      message = "Password mismatch."
      status = true
    end
    [status, message]
  end

  def self.social_media_sign_up(data)
    data = data.with_indifferent_access

    member_profile = MemberProfile.new
    member_profile.attributes = data[:member_profile]

    auth = UserAuthentication.find_from_social_data(member_profile.user.user_authentications.first)

    if auth.blank?
      if member_profile.user.email.present?
        user = User.find_by_email(member_profile.user.email)
      elsif member_profile.user.username.present?
        user = User.find_by_username(member_profile.user.username)
      end

      if user.present?
        UserAuthentication.create_from_social_data(member_profile.user.user_authentications.first, user)
        # user.current_sign_in_at = Time.now
        user.following_sync_datetime= nil
        user.nearme_sync_datetime   = nil
        user.trending_sync_datetime = nil
        user.last_subscription_time = nil
        user.save!
        social_sign_up_response(data, user.profile)
      else
        if data[:country_code].present?
          member_profile.country_id = Country.find_by_iso(data[:country_code]).try(:d)
        end

        password = SecureRandom.hex(10)
        member_profile.user.password = password
        member_profile.user.password_confirmation = password
        member_profile.is_profile_public = true #should be in migration default false : Later
        if member_profile.save
          user = member_profile.user
          # user.current_sign_in_at = Time.now
          user.following_sync_datetime= nil
          user.nearme_sync_datetime   = nil
          user.trending_sync_datetime = nil
          user.last_subscription_time = nil
          user.save!
          social_sign_up_response(data, member_profile)
        else
          resp_data = ''
          resp_request_id = data[:request_id] if data && data[:request_id].present?
          resp_status = 0
          resp_message = 'errors'

          resp_errors = error_messages(member_profile)
          JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
        end
      end
    else
      # SignIn Here
      user = auth.user
      # user.current_sign_in_at = Time.now
      user.following_sync_datetime= nil
      user.nearme_sync_datetime   = nil
      user.trending_sync_datetime = nil
      user.last_subscription_time = nil
      user.save!
      social_sign_up_response(data, auth.user.profile)
    end
  end

  def self.social_sign_up_response(data, profile)
    user = profile.user
    user_sessions = UserSession.where("device_uuid = ? AND user_id != ?", data[:user_session][:device_uuid], user.id)
    user_sessions.destroy_all if user_sessions.present?
  
    user_session = user.user_sessions.where(device_uuid: data[:user_session][:device_uuid]).try(:first) || user.user_sessions.build(data[:user_session])
    user_session.auth_token = SecureRandom.hex(100)
    user_session.session_status = 'open'
    user_session.save!
  
    resp_data = profile.member_profile(user_session.auth_token)
    resp_request_id = data[:request_id]
    resp_status = 1
    resp_message = 'success'
    resp_errors = ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.update(data, current_user)
    begin
      data = data.with_indifferent_access
      profile = current_user.profile
      if data[:user].present?
        current_user.update_attributes(data[:user])
        current_user = User.find_by_id(current_user.id)
      end
      if profile.update_attributes(data[:member_profile])
        resp_data    = current_user.profile.member_profile
        resp_status  = 1
        resp_message = 'success'
        resp_errors  = ''
      else
        resp_data    = {}
        resp_status  = 0
        resp_message = 'error'
        resp_errors  = error_messages(profile)
      end
    rescue Exception => e
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.get_profile(data, current_user)
    begin
      data          = data.with_indifferent_access
      profile       = MemberProfile.find_by_id(data[:member_profile_id])
      resp_data     = profile.member_profile
      resp_status   = 1
      resp_message  = 'success'
      resp_errors   = ''
    rescue Exception => e
      resp_data     = ''
      resp_status   = 0
      paging_data   = ''
      resp_message  = 'error'
      resp_errors   = e
    end
    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.get_drop_down_data(data, current_user)
    occupations          = Occupation.all
    occupations = occupations.as_json(
        only:[:id, :name]
    )
    college_majors       = CollegeMajor.all
    college_majors = college_majors.as_json(
             only:[:id, :name]
    )
    
    relationship_status = RelationshipStatus.all
    relationship_status = relationship_status.as_json(
        only:[:id, :name]
    )
    political_views     = PoliticalView.all
    political_views = political_views.as_json(
        only:[:id, :name]
    )
    
    religions            = Religion.all
    religions = religions.as_json(
        only:[:id, :name]
    )
    languages            = Language.all
    languages = languages.as_json(
        only:[:id, :name]
    )
    ethnic_backgrounds   = EthnicBackground.all
    ethnic_backgrounds = ethnic_backgrounds.as_json(
        only:[:id, :name]
    )
    resp_data       = {occupations: occupations, relationship_status: relationship_status, political_views: political_views, religions: religions,  languages: languages, ethnic_backgrounds: ethnic_backgrounds, college_majors: college_majors}.as_json
    resp_status     = 1
    resp_message    = 'success'
    resp_errors     = ''
    resp_request_id = ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.error_messages(error_array)
    error_string = ''
    error_array.errors.full_messages.each do |message|
      error_string += message + ', '
    end
    error_string
  end

  def self.profile_timeline(data, current_user)
    begin
      data         = data.with_indifferent_access
      max_post_date = data[:max_post_date] || Time.now
      min_post_date = data[:min_post_date] || Time.now

      profile      = MemberProfile.find_by_id(data[:member_profile_id])
      if data[:type].present?
        if data[:type] == AppConstants::NEAR_ME
          if data[:latitude].present? && data[:longitude].present?
            latitude  = data[:latitude]
            longitude = data[:longitude]
          else
            latitude  = profile.latitude
            longitude = profile.longitude
          end
          event_ids = Event.within(profile.near_event_search, :origin => [latitude, longitude]).pluck(:id)
          # posts = Post.within(profile.near_event_search, :origin => [latitude, longitude])
          # posts = posts.where(is_deleted: false, is_post_public: true)
          posts = Post.where(event_id: event_ids, is_deleted: false, is_post_public: true)
        end
        if data[:type] == AppConstants::FOLLOWING
          following_ids = profile.member_followings.where(following_status: AppConstants::ACCEPTED).pluck(:following_profile_id)
          posts = Post.where("(member_profile_id IN (?)) AND is_deleted = ? OR is_post_public = ?", following_ids, false, true).distinct
        end
        if data[:type] == AppConstants::TRENDING
          posts      = Post.order("RANDOM()").order("created_at DESC")
          hash_tags  = Hashtag.order("RANDOM()").order("created_at DESC")
        end
      else
        posts   = profile.posts
      end

      if data[:max_post_date].present?
        posts = posts.where("created_at > ?", max_post_date)
      elsif data[:min_post_date].present?
        posts = posts.where("created_at < ?", min_post_date)
      end
      
      if data[:filter_type].present?
        post_ids = posts.pluck(:id)
        posts = Post.joins(:post_attachments).where(id: post_ids, post_attachments: {attachment_type: data[:filter_type]})
      end
      
      posts = posts.order("created_at DESC")
      posts = posts.limit(@@limit)
      
      if posts.present?
        Post.where("created_at > ?", posts.first.created_at, member_profile_id: profile.id).present? ? previous_page_exist = true : previous_page_exist = false
        Post.where("created_at < ?", posts.last.created_at,  member_profile_id: profile.id).present? ? next_page_exist = true : next_page_exist = false
      end
      
      paging_data    = {next_page_exist: next_page_exist, previous_page_exist: previous_page_exist}
      if data[:type] == AppConstants::TRENDING
        resp_data    =  Post.trending_api_loop_response(posts, hash_tags, false, current_user)
      else
        resp_data    = Post.timeline_posts_array_response(posts, profile, current_user)
      end
      resp_status   = 1
      resp_message  = 'TimeLine'
      resp_errors   = ''
    rescue Exception => e
      resp_data    = {}
      resp_status  = 0
      paging_data  = ''
      resp_message = 'error'
      resp_errors  = e
    end
    open_session    = OpenSession.find_by_user_id_and_media_type(current_user.id, data[:type]) if data[:type].present?
    if open_session.present?
      resp_data     = resp_data.merge!(session_id: open_session.session_id)
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.update_user_location(data, current_user)
    begin
      data    = data.with_indifferent_access
      profile = current_user.profile
      if profile.update_attributes(data[:member_profile])
        open_session    = OpenSession.find_by_user_id_and_media_type(current_user.id, AppConstants::NEAR_ME)
        if open_session.present?
          posts = Post.within(profile.near_event_search, :origin => [profile.latitude, profile.longitude])
          posts = posts.where(is_post_public: true)
          posts = posts.order("created_at DESC")
          posts = posts.limit(@limit)
          start = 'start_sync'
          
          if posts.present?
            if start == 'start_sync' && posts.present?
              Post.where("created_at < ?", posts.last.created_at).present? ? next_page_exist = true : next_page_exist = false
            end
            sync_object             = profile.synchronizations.first ||  profile.synchronizations.build
            sync_object.sync_token  = SecureRandom.uuid
            sync_object.sync_type   = AppConstants::NEAR_ME
            sync_object.synced_date = posts.first.created_at
            sync_object.save!
  
            resp_data       = Post.posts_array_response(posts, profile, sync_object.sync_token)
            resp_data       = resp_data.merge!(session_id: open_session.session_id)
            paging_data     = {next_page_exist: next_page_exist}
            # Broadcast here
            resp_status     = 1
            resp_request_id = ''
            resp_message    = 'Posts'
            resp_errors     = ''
            response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, start: start, type: 'Sync', paging_data: paging_data)
            PostJob.perform_later response, current_user.id, nil, 'near_me' if response.present?
          end
        end
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'error'
        resp_errors     = error_messages(profile)
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
end


# == Schema Information
#
# Table name: member_profiles
#
#  id                :integer          not null, primary key
#  photo             :string           default("http://bit.ly/25CCXzq")
#  country_id        :integer
#  school_name       :string
#  is_profile_public :boolean
#  default_group_id  :integer
#  gender            :string
#  dob               :string
#  promotion_updates :boolean          default(FALSE)
#  state_id          :integer
#  city_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sport_id          :integer
#  sport_position_id :integer
#  sport_level_id    :integer
#  account_type      :string
#
