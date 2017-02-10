class Event < ApplicationRecord
  
  include JsonBuilder
  include PgSearch
  
  belongs_to :member_profile
  belongs_to :category
  has_many   :event_attachments, dependent: :destroy
  has_many   :event_co_hosts,    dependent: :destroy
  has_many   :event_hash_tags,   dependent: :destroy
  has_many   :hashtags, through: :event_hash_tags
  has_many   :event_members,     dependent: :destroy
  has_many   :synchronizations, as: :media
  has_many   :posts

  validates_presence_of :event_name, :start_date, :end_date, :location, :longitude, :latitude, :category_id
  accepts_nested_attributes_for :event_members, :event_co_hosts, :event_attachments, :hashtags
  
  @@limit           = 3
  @@current_profile = nil

  acts_as_mappable default_units: :kms, lat_column_name: :latitude, lng_column_name: :longitude
  pg_search_scope :search_by_title,
    against: [:event_name, :event_details],
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }

  def self.event_create(data, current_user)
    begin
      sync_event_id = 0
      data    = data.with_indifferent_access
      profile = current_user.profile
      event   = profile.events.build(data[:event])
      if event.save
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
        sync_event_id   = event.id
        resp_data       = {}
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
    [response, sync_event_id]
  end

  def self.show_event(data, current_user)
    begin
      data  = data.with_indifferent_access
      event = Event.where(id: data[:event][:id])
      resp_data       = events_response(event)
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
  
    resp_data       = events_response(events, sync_object.sync_token)
    resp_status     = 1
    resp_request_id = ''
    resp_message    = 'Events'
    resp_errors     = ''
    response        = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
    ProfileJob.perform_later response, user.id
  end

  def self.events_response(events, sync_token=nil)
    events = events.as_json(
        only: [:id, :event_name, :member_profile_id, :location, :latitude, :longitude, :radius, :event_details, :is_frields_allowed, :is_public, :is_paid, :category_id, :event_type, :start_date, :end_date, :created_at, :updated_at, :custom_event, :message_from_host],
        include:{
            member_profile:{
                only: [:id, :photo],
                include:{
                    user:{
                        only: [:id, :first_name, :email, :last_name]
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
                only:[:id, :event_id, :member_profile_id]
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
      { events: events }.as_json.merge!(sync_token: sync_token)
    else
      { events: events }.as_json
    end

  end
  
  def self.event_list_horizontal(data, current_user)
    begin
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i
      if data[:type] == 'search'
        events  = search_event_list(data)
      elsif data[:type] == 'upcoming' && data[:list_type] == 'day'
        events  = Event.where('Date(start_date) = ?',  Date.today)
      elsif data[:type] == 'upcoming' && data[:list_type] == 'np_day'
        events  = Event.where('Date(start_date) = ?',  Date.today + 1.day)
      elsif data[:type] == 'upcoming' && data[:list_type] == 'week'
        events  = Event.where('Date(start_date) > ? AND Date(start_date) <= ?', Date.today + 1.day, Date.today + 1.week)
      elsif data[:type] == 'upcoming' && data[:list_type] == 'all'
        events  = Event.where('Date(start_date) > ?', Date.today + 1.week)
      elsif data[:type] == 'past' && data[:list_type] == 'day'
        events  = Event.where('Date(start_date) = ?',  Date.today - 1.day)
      elsif data[:type] == 'past' && data[:list_type] == 'np_day'
        events  = Event.where('Date(start_date) = ?',  Date.today - 2.day)
      elsif data[:type] == 'past' && data[:list_type] == 'week'
        events  = Event.where('Date(start_date) >= ? AND Date(start_date) < ?', Date.today - 1.week, Date.today - 2.day)
      elsif data[:type] == 'past' && data[:list_type] == 'all'
        events  = Event.where('Date(start_date) < ?', Date.today - 1.week)
      end
      events           =  events.page(page.to_i).per_page(per_page.to_i)
      paging_data      =  JsonBuilder.get_paging_data(page, per_page, events)
      events =  events.as_json(
          only:[:id, :event_name, :event_details, :start_date, :end_date, :location, :message_from_host],
          include:{
              member_profile:{
                  only: [:id, :photo],
                  include:{
                      user:{
                          only: [:id, :first_name, :email, :last_name]
                      }
                  }
              },
              event_attachments:{
                  only:[:id, :event_id, :attachment_type, :message, :attachment_url, :thumbnail_url, :poster_skin]
              },
              event_co_hosts:{
                  only:[:id, :event_id, :member_profile_id]
              },
              hashtags:{
                  only:[:id, :name]
              }
          }
      )
      resp_data       = {events: events}.as_json
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
      events = Event.search_by_title(data[:keyword])
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
    if data[:is_paid].present?
      if data[:is_paid] == 'free'
        events = events.where(is_paid: false)
      elsif data[:is_paid] == 'paid'
        events = events.where(is_paid: true)
      end
    end
    events
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
