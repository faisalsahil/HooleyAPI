class Event < ApplicationRecord
  
  include JsonBuilder
  include PgSearch
  include AppConstants
  
  belongs_to :member_profile
  belongs_to :category
  
  has_many   :event_attachments, dependent: :destroy
  has_many   :event_co_hosts,    dependent: :destroy
  has_many   :event_hash_tags,   dependent: :destroy
  has_many   :hashtags, through: :event_hash_tags
  has_many   :event_members,     dependent: :destroy
  has_many   :event_bookmarks,   dependent: :destroy
  has_many   :synchronizations, as: :media,       dependent: :destroy
  has_many   :comments,         as: :commentable, dependent: :destroy
  has_many   :likes,            as: :likable,     dependent: :destroy
  has_many   :posts,                              dependent: :destroy
  
  validates_presence_of :start_date, :end_date, :location, :longitude, :latitude, :category_id, :member_profile_id
  accepts_nested_attributes_for :event_members, :event_co_hosts, :event_attachments, :hashtags
  
  @@limit           = 10
  @@current_profile = nil

  acts_as_mappable default_units: :miles, lat_column_name: :latitude, lng_column_name: :longitude
  pg_search_scope :search_by_title,
    against: [:event_name, :event_details],
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }

  def post_count
    self.posts.count
  end
  
  def self.event_create(data, current_user)
    begin
      sync_event_id = 0
      data    = data.with_indifferent_access
      profile = current_user.profile
      event   = profile.events.build(data[:event])
      if event.save
        # creating hashtags for event
        data[:hash_tags] && data[:hash_tags].each do |tag|
          hash_tag = Hashtag.find_by_name(tag[:tag_name])
          if hash_tag.present?
            hash_tag.count = hash_tag.count + 1
            hash_tag.save!
          else
            hash_tag = Hashtag.create name: tag[:tag_name]
          end
          event_hash_tag = EventHashTag.find_by_event_id_and_hashtag_id(event.id, hash_tag.id)
          if not event_hash_tag.present?
            event_hash_tag            = event.event_hash_tags.build
            event_hash_tag.hashtag_id = hash_tag.id
            event_hash_tag.save
          end
        end
        # creating event members
        event.event_members.each do |member|
          member.is_invited = true
          member.save
        end
        
        sync_event_id   = event.id
        resp_data       = events_response(event, current_user)
        resp_status     = 1
        resp_message    = 'Event Created'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = event.errors.messages
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    [response, sync_event_id, data[:is_all_invited]]
  end
  
  def self.show_event(data, current_user)
    begin
      data  = data.with_indifferent_access
      event = Event.where(id: data[:event][:id])
      resp_data       = events_response(event, current_user)
      resp_status     = 1
      resp_message    = 'Event details'
      resp_errors     = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.event_sync_to_members(event_id, current_user)
    events = Event.where(id: event_id)
    # Sync to current user
    make_event_sync_response(current_user, events)
    
    member_profile_ids  = []
    member_profile_ids << events.first.event_members.pluck(:member_profile_id)
    member_profile_ids << events.first.event_co_hosts.pluck(:member_profile_id)
    # Followers
    # member_profile_ids << MemberFollowing.where("following_profile_id = ? AND following_status = ? ", current_user.profile_id, AppConstants::ACCEPTED).pluck(:member_profile_id)
   
    users = User.where(profile_id: member_profile_ids.flatten.uniq)
    users && users.each do |user|
      if user != current_user
        make_event_sync_response(user, events)
      end
    end
  end

  def self.make_event_sync_response(user, events)
    sync_object                   = events.first.synchronizations.build
    sync_object.member_profile_id = user.profile_id
    sync_object.sync_token        = SecureRandom.uuid
    sync_object.synced_date       = events.first.updated_at
    sync_object.save!
  
    resp_data       = events_response(events, user, sync_object.sync_token)
    resp_status     = 1
    resp_request_id = ''
    resp_message    = 'Events'
    resp_errors     = ''
    response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
    ProfileJob.perform_later response, user.id
  end
  
  def self.event_list_horizontal(data, current_user)
    begin
      data     = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      
      # events   = Event.where(is_public: true)
      events = Event.where('member_profile_id = ? OR is_public = ?', current_user.profile_id, true)
      if data[:type].present? && data[:type] == AppConstants::SEARCH
        events  = search_event_list(data)
      elsif data[:type].present? && data[:type] == AppConstants::UPCOMING && data[:list_type] == AppConstants::DAY
        events  = events.where('Date(start_date) = ?',  Date.today)
      elsif data[:type].present? && data[:type] == AppConstants::UPCOMING && data[:list_type] == AppConstants::NP_DAY
        events  = events.where('Date(start_date) = ?',  Date.today + 1.day)
      elsif data[:type].present? && data[:type] == AppConstants::UPCOMING && data[:list_type] == AppConstants::WEEK
        events  = events.where('Date(start_date) > ? AND Date(start_date) <= ?', Date.today + 1.day, Date.today + 1.week)
      elsif data[:type].present? && data[:type] == AppConstants::UPCOMING && data[:list_type] == AppConstants::ALL
        events  = events.where('Date(start_date) > ?', Date.today + 1.week)
      elsif data[:type].present? && data[:type] == AppConstants::PAST && data[:list_type] == AppConstants::DAY
        events  = events.where('Date(start_date) = ?',  Date.today - 1.day)
      elsif data[:type].present? && data[:type] == AppConstants::PAST && data[:list_type] == AppConstants::NP_DAY
        events  = events.where('Date(start_date) = ?',  Date.today - 2.day)
      elsif data[:type].present? && data[:type] == AppConstants::PAST && data[:list_type] == AppConstants::WEEK
        events  = events.where('Date(start_date) >= ? AND Date(start_date) < ?', Date.today - 1.week, Date.today - 2.day)
      elsif data[:type].present? && data[:type] == AppConstants::PAST && data[:list_type] == AppConstants::ALL
        events  = events.where('Date(start_date) < ?', Date.today - 1.week)
      end

      #===============   Filter events here  ===========================
      if data[:filter_type].present? && ( data[:filter_type] == AppConstants::INVITED || data[:filter_type] == AppConstants::REGISTERED )
        events = events.joins(:event_members).where(event_members: {member_profile_id: current_user.profile_id, invitation_status: data[:filter_type]})
      end

      if data[:filter_type].present? && data[:filter_type] == AppConstants::BOOKMARK
        events = events.joins(:event_bookmarks).where(event_bookmarks: {member_profile_id: current_user.profile_id, is_bookmark: true})
      end

      if data[:filter_type].present? && data[:filter_type] == AppConstants::ALL
        events    =  Event.where(is_public: true)
      end

      if data[:keyword].present?
        events    =  events.where('lower(event_name) like ? OR lower(event_details) like ?', "%#{data[:keyword]}%".downcase, "%#{data[:keyword]}%".downcase)
      end
      # =================================================================
      
      events           =  events.page(page.to_i).per_page(per_page.to_i)
      paging_data      =  JsonBuilder.get_paging_data(page, per_page, events)
      
      resp_data       = events_response(events, current_user)
      resp_status     = 1
      resp_message    = 'Event list'
      resp_errors     = ''
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      paging_data     = ''
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  def self.search_event_list(data)
    if data[:keyword].present?
      # events = Event.search_by_title(data[:keyword])
      events = Event.where('lower(event_name) like ? OR lower(event_details) like ?', "%#{data[:keyword]}%".downcase, "%#{data[:keyword]}%".downcase)
      events = events.where(is_public: true)
    end
    if data[:date].present?
      events = events.where('Date(start_date) = ?', data[:date])
    end
    if data[:location].present?
      events = events.where('lower(location) like ?', data[:location])
    end
    if data[:radius].present? && data[:latitude].present? && data[:longitude].present?
      events = events.within(data[:radius], :origin => [data[:latitude], data[:longitude]])
    end
    if data[:category_id].present?
      events = events.where(category_id: data[:category_id])
    end
    if data[:event_type].present?
      if data[:event_type] == 'free'
        events = events.where(is_paid: false)
      elsif data[:event_type] == 'paid'
        events = events.where(is_paid: true)
      end
    end
    events
  end
  
  def self.event_posts(data, current_user)
    begin
      # per_page = (data[:per_page] || @@limit).to_i
      # page     = (data[:page] || 1).to_i
      max_post_date = data[:max_post_date] || Time.now
      min_post_date = data[:min_post_date] || Time.now
      
      member_profile = current_user.profile
      event          = Event.find_by_id(data[:event_id])
      if event.present?
        posts   = event.posts.where(is_deleted: false)
        if data[:type].present? && data[:type] ==  AppConstants::ME_MEDIA
          posts = posts.where(member_profile_id: current_user.profile_id)
        end
        
        if data[:type].present? && data[:type] ==  AppConstants::FRIENDS
          profile_ids =  member_profile.member_followings.where(following_status: AppConstants::ACCEPTED, is_deleted:false).pluck(:following_profile_id)
          posts       =  posts.where(member_profile_id: profile_ids)
        end

        if data[:type].present? && data[:type] ==  AppConstants::LIKED
          posts = posts.order('post_likes_count DESC')
          # posts = Post.joins(:likes).select("posts.*, COUNT('likes.id') likes_count").where(likes: {likable_type: 'Post', is_like: true}).group('posts.id').order('likes_count DESC')
        end

        if data[:type].present? && data[:type] ==  AppConstants::ALL
          posts  =  event.posts
        end

        if data[:max_post_date].present?
          posts = posts.where("created_at > ?", max_post_date)
        elsif data[:min_post_date].present?
          posts = posts.where("created_at < ?", min_post_date)
        end
        posts = posts.order("created_at DESC")
        posts = posts.limit(@@limit)
        
        if data[:filter_type].present?
          post_ids = posts.pluck(:id)
          posts    = Post.joins(:post_attachments).where(id: post_ids, post_attachments: {attachment_type: data[:filter_type]})
          posts = posts.order("created_at DESC")
          # posts    = posts.joins(:post_attachments).where(post_attachments: {attachment_type: data[:filter_type]})
        end

        if posts.present?
          Post.where("created_at > ?", posts.first.created_at).present? ? previous_page_exist = true : previous_page_exist = false
          Post.where("created_at < ?", posts.last.created_at).present? ? next_page_exist = true : next_page_exist = false
        end
        
        # posts           =  posts.page(page.to_i).per_page(per_page.to_i)
        # paging_data     =  JsonBuilder.get_paging_data(page, per_page, posts)
        paging_data     = {previous_page_exist: previous_page_exist, next_page_exist: next_page_exist}
        resp_data       =  Post.posts_array_response(posts, current_user.profile)
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'Event not found.'
        paging_data     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      paging_data     = ''
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
  
  def self.profile_events(data, current_user)
    begin
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      member_profile = MemberProfile.find_by_id(data[:member_profile_id])
      if member_profile.present?
        if member_profile.id == current_user.profile_id
          # event_ids= EventMember.where(member_profile_id: member_profile.id).pluck(:event_id)
          # events   = Event.where('member_profile_id = ? OR id IN(?)', member_profile.id, event_ids)
          events = member_profile.events
        else
          # event_ids = EventMember.where(member_profile_id: member_profile.id).pluck(:event_id)
          # events    = Event.where('(member_profile_id = ? OR id IN(?)) AND is_public = ?', member_profile.id, event_ids, true)
          events = member_profile.events.where(is_public: true)
        end
        
        if data[:search_key].present?
          events = events.where('lower(event_name) like ? OR lower(event_details) like ?', "%#{data[:search_key]}%".downcase, "%#{data[:search_key]}%".downcase)
        end
        
        events   =  events.page(page.to_i).per_page(per_page.to_i)
        paging_data     =  JsonBuilder.get_paging_data(page, per_page, events)
        resp_data       = events_response(events, current_user)
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        paging_data     =  ''
        resp_data       = {}
        resp_status     = 0
        resp_message    = 'error'
        resp_errors     = 'Profile not found'
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      paging_data     = ''
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
  
  def self.event_guests(data, current_user)
    begin
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      event_members  = EventMember.where(event_id: data[:event_id])
      if data[:type].present? &&  data[:type] ==  AppConstants::REGISTERED
        event_members  = event_members.where(invitation_status: AppConstants::REGISTERED)
      end

      if data[:type].present? &&  data[:type] ==  AppConstants::ON_WAY
        event_members  = event_members.where(visiting_status: AppConstants::ON_WAY)
      end
      
      if data[:type].present? &&  data[:type] ==  AppConstants::REACHED
        event_members  = event_members.where(visiting_status: AppConstants::REACHED)
      end

      if data[:type].present? &&  data[:type] ==  AppConstants::GONE
        event_members  = event_members.where(visiting_status: AppConstants::GONE)
      end
      
      profile_ids     = event_members.pluck(:member_profile_id)
      member_profiles = MemberProfile.where(id: profile_ids)

      if data[:search_key].present?
        # profile_ids = member_profiles.pluck(:id)
        users = User.where(profile_id: profile_ids)
        profile_ids = users.where('lower(first_name) like ? OR lower(last_name) like ? OR email like ? OR lower(username) like ? ', "%#{data[:search_key]}%".downcase, "%#{data[:search_key]}%".downcase, "%#{data[:search_key]}%".downcase, "%#{data[:search_key]}%".downcase).pluck(:profile_id)
        member_profiles  = MemberProfile.where(id: profile_ids)
      end
      
      if data[:filter_type].present? &&  data[:filter_type]
        member_profiles = member_profiles.where(gender: data[:filter_type])
      end
      
      member_profiles  =  member_profiles.page(page.to_i).per_page(per_page.to_i)
      paging_data      =  JsonBuilder.get_paging_data(page, per_page, member_profiles)
      if member_profiles.present?
        member_profiles  =  member_profiles.to_xml(
           only: [:id, :photo, :contact_address, :dob],
           :procs => Proc.new { |options, member_profile|
             options[:builder].tag!('is_friend',   MemberFollowing.is_friend(member_profile, current_user.profile_id))
           },
           include:{
               user: {
                   only: [:id, :first_name, :last_name, :email]
               }
           }
        )
        resp_data  =  Hash.from_xml(member_profiles).as_json
      else
        resp_data  = {member_profiles: []}.as_json
      end
      resp_status     = 1
      resp_message    = 'success'
      resp_errors     = ''
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      paging_data     = ''
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end
  
  def self.event_attending_status(data, current_user)
    begin
      event_member = EventMember.find_by_member_profile_id_and_event_id(current_user.profile_id, data[:event_id])
      if event_member.present?
        if data[:visiting_status] == AppConstants::ON_WAY || data[:visiting_status] == AppConstants::REACHED || data[:visiting_status] == AppConstants::GONE
          event_member.visiting_status = data[:visiting_status]
          event_member.save!
          event  = event_member.event
          if data[:visiting_status] == AppConstants::ON_WAY
            message  = AppConstants::MESSAGE_ON_THE_WAY
          elsif data[:visiting_status] == AppConstants::REACHED
            message  = AppConstants::MESSAGE_REACHED
          elsif data[:visiting_status] == AppConstants::GONE
            message  = AppConstants::MESSAGE_GONE
          end
          comment  = event.comments.build(member_profile_id: current_user.profile_id, comment: message)
          comment.save!
          comments =  Comment.where(id: comment.id)
          broadcast_response  =  Comment.comments_response(comments, current_user, nil, event)
          resp_data     = {}
          resp_status   = 1
          resp_message  = 'success'
          resp_errors   = ''
        else
          resp_data          = {}
          broadcast_response = ''
          resp_status   = 0
          resp_message  = 'error'
          resp_errors   = 'Visiting Status is not correct.'
        end
      else
        resp_data          = {}
        broadcast_response = ''
        resp_status     = 0
        resp_message    = 'error'
        resp_errors     = 'You\'re not registered.'
      end
      resp_request_id = ''
      resp_request_id = data[:request_id] if data[:request_id].present?
      response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
      [response, broadcast_response]
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
      resp_request_id = ''
      resp_request_id = data[:request_id] if data[:request_id].present?
      JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
    end
  end
  
  def self.event_add_members(data, current_user)
    begin
      event = Event.find_by_id(data[:event][:id])
      if current_user.profile_id == event.member_profile_id || event.is_friends_allowed?
        event_members = data[:event][:event_members_attributes]
        
        profile_ids = []
        
        event_members.each do |member|
          event_member = EventMember.find_by_member_profile_id_and_event_id(member[:member_profile_id], event.id) || event.event_members.build
          if event_member.new_record?
            event_member.member_profile_id = member[:member_profile_id]
            event_member.is_invited        = true
            event_member.save
            profile_ids << event_member.member_profile_id
          end
        end
        # Send notification
        name  = current_user.username || current_user.first_name || current_user.email
        alert = name + ' ' + AppConstants::INVITED_EVENT
        screen_data = {event_id: event.id}.as_json
        member_profiles = MemberProfile.where(id: profile_ids, is_hooly_invite_alert: true).includes(:user)
        member_profiles&.each do |profile|
          Notification.send_hooly_notification(profile.user, alert, AppConstants::EVENT, true, screen_data)
        end
        
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'success'
        resp_errors     = ''
      else
        resp_data       = {}
        resp_status     = 1
        resp_message    = 'You are not allowed to invite friends.'
        resp_errors     = ''
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id = ''
    resp_request_id = data[:request_id] if data[:request_id].present?
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.events_response(events, current_user, sync_token=nil)
    if events.present?
      events = events.to_xml(
          only:[:id, :event_name, :member_profile_id, :location, :latitude, :longitude, :radius, :event_details, :is_friends_allowed, :is_public, :is_paid, :category_id, :event_type, :start_date, :end_date, :created_at, :updated_at, :custom_event, :message_from_host, :is_deleted],
          methods:[:post_count],
          :procs => Proc.new { |options, event|
            options[:builder].tag!('is_bookmarked',   EventBookmark.is_bookmarked(event, current_user.profile_id))
            options[:builder].tag!('is_registered',   EventMember.is_registered(event, current_user.profile_id))
            options[:builder].tag!('visiting_status', EventMember.visiting_status(event, current_user.profile_id))
          },
          include:{
              member_profile:{
                  only: [:id, :photo],
                  include:{
                      user:{
                          only: [:id, :first_name, :last_name, :email]
                      }
                  }
              },
              category:{
                  only:[:id, :name]
              },
              event_attachments:{
                  only:[:id, :event_id, :attachment_type, :message, :attachment_url, :thumbnail_url, :poster_skin]
              },
              event_co_hosts:{
                  only:[:id, :event_id, :member_profile_id],
                  include:{
                      member_profile: {
                          only: [:id, :photo],
                          include: {
                              user: {
                                  only: [:id, :first_name, :last_name]
                              }
                          }
                      }
                  }
              },
              hashtags:{
                  only:[:id, :name]
              },
              event_members:{
                  only: [:id],
                  include:{
                      member_profile: {
                          only: [:id, :photo],
                          include: {
                              user: {
                                  only: [:id, :first_name, :last_name]
                              }
                          }
                      }
                  }
              }
          }
      )
      if sync_token.present?
        Hash.from_xml(events).as_json.merge!(sync_token: sync_token)
      else
        Hash.from_xml(events).as_json
      end
    else
      {events: []}.as_json
    end
  end
  
  def self.invite_all_friends(event_id, current_user)
    ids = []
    ids << MemberFollowing.where(member_profile_id: current_user.profile_id, following_status: AppConstants::ACCEPTED).pluck(:following_profile_id)
    ids << MemberFollowing.where(following_profile_id: current_user.profile_id, following_status: AppConstants::ACCEPTED).pluck(:member_profile_id)
    ids = ids.flatten.uniq
    event_profile_ids = EventMember.where(event_id: event_id).pluck(:member_profile_id)
    ids&.each do |profile_id|
      if not event_profile_ids.include? profile_id
        EventMember.create!(event_id: event_id, member_profile_id: profile_id, is_invited: true)
      end
    end
  end
  
  def self.event_creation_notification(event_id, current_user)
    begin
      event = Event.find_by_id(event_id)
      if event.is_public
        name  = current_user.username || current_user.first_name || current_user.email
        alert = name + ' ' + AppConstants::Event_CREATED
        screen_data = {event_id: event_id}.as_json
        
        member_profiles  =  MemberProfile.within(50, :origin => [event.latitude, event.longitude]).where(is_near_me_event_alert: true, is_hooly_invite_alert: true)
        member_profiles && member_profiles.each do |profile|
          current_location = Geokit::LatLng.new(profile.latitude, profile.longitude)
          destination      = "#{event.latitude},#{event.longitude}"
          distance         = current_location.distance_to(destination)  # return in miles
          if distance.present? && distance.round <= profile.near_event_search.round
             Notification.send_hooly_notification(profile.user, alert, AppConstants::EVENT, true, screen_data)
          end
        end

        event_member_ids = []
        event_member_ids << event.event_members.pluck(:member_profile_id)
        event_member_ids << event.event_co_hosts.pluck(:member_profile_id)
        event_member_ids =  event_member_ids.flatten.uniq
        users  = User.where(profile_id: event_member_ids)
        alert = name + ' ' + AppConstants::INVITED_EVENT
        users&.each do |user|
          Notification.send_hooly_notification(user, alert, AppConstants::EVENT, true, screen_data)
        end
      end
    rescue Exception => e
      resp_data       = {}
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
  end
end

# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string
#  country_id        :integer
#  state_id          :integer
#  city_id           :integer
#  organization      :text
#  location          :text
#  description       :text
#  cost              :integer
#  currency_id       :integer
#  camp_website      :text
#  start_date        :datetime
#  end_date          :datetime
#  upload            :string
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
