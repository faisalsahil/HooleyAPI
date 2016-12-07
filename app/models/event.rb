class Event < ApplicationRecord
  include JsonBuilder

  belongs_to :member_profile
  belongs_to :currency
  has_many :event_sports
  has_many :sports, through: :event_sports
  accepts_nested_attributes_for :event_sports

  @@limit           = 10
  @@current_profile = nil
  include PgSearch
  pg_search_scope :search_by_title,
                  against: :description,
                  using: {
                      tsearch: {
                          any_word: true,
                          dictionary: "english"
                      }
                  }

  def self.event_create(data, current_user)
    begin
      data    = data.with_indifferent_access
      profile = current_user.profile
      event   = profile.events.build(data[:event])
      if event.save
        resp_data       = ''
        resp_status     = 1
        resp_message    = 'Event Created'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = event.errors.messages
      end
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

  def self.event_search(data, current_user)
    begin
      data     = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      events   = Event.all
      if data[:search][:keyword].present?
        events  = events.where("lower(name) like ? OR lower(description) like ?", "%#{data[:search][:keyword]}%".downcase, "%#{data[:search][:keyword]}%".downcase)
      end

      if data[:search][:country_id].present?
        events  = events.where('country_id = ?', data[:search][:country_id])
      end

      if data[:search][:state_id].present?
        events  = events.where('state_id = ?', data[:search][:state_id])
      end

      if data[:search][:sport_id].present?
        event_records_ids = events.pluck(:id)
        events            = Event.joins(:event_sports).where("event_sports.event_id IN (?) AND event_sports.sport_id = ?", event_records_ids, data[:search][:sport_id])
      end

      if data[:search][:sport_position_id].present?
        event_records_ids = events.pluck(:id)
        events            = Event.joins(:event_sports).where("event_sports.event_id IN (?) AND event_sports.sport_position_id = ?", event_records_ids, data[:search][:sport_position_id])
      end

      if events.present?
        events            = events.page(page.to_i).per_page(per_page.to_i)
        paging_data       = JsonBuilder.get_paging_data(page, per_page, events)
        resp_data       = {events: events}
        resp_status     = 1
        resp_message    = 'Event list'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        paging_data     = nil
        resp_message    = 'error'
        resp_errors     = 'No Record found'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = nil
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  # def self.event_list(data, current_user)
  #   begin
  #     data = data.with_indifferent_access
  #
  #     per_page    = (data[:per_page] || @@limit).to_i
  #     page        = (data[:page] || 1).to_i
  #     events      = Event.all.order('created_at DESC')
  #     events      = events.page(page.to_i).per_page(per_page.to_i)
  #     paging_data = JsonBuilder.get_paging_data(page, per_page, events)
  #
  #     resp_data       = events_response(events)
  #     resp_status     = 1
  #     resp_message    = 'Event List'
  #     resp_errors     = ''
  #   rescue Exception => e
  #     resp_data       = ''
  #     resp_status     = 0
  #     paging_data     = ''
  #     resp_message    = 'error'
  #     resp_errors     = e
  #   end
  #   resp_request_id   = data[:request_id]
  #   JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  # end

  def self.events_response(events)
    events = events.as_json(
        only:    [:id, :name, :country_id, :state_id, :city_id, :organization, :location, :description, :cost, :currency_id, :camp_website, :start_date, :end_date, :upload, :member_profile_id, :created_at, :updated_at],
        include: {
            currency:     {
                only: [:id, :name, :code]
            },
            event_sports: {
                only:    [:id],
                include: {
                    sport:          {
                        only: [:id, :name]
                    },
                    sport_position: {
                        only: [:id, :name]
                    }

                }
            }
        }
    )

    { events: events }.as_json
  end

  def self.event_response(event)
    event = event.as_json(
        only:    [:id, :name, :country_id, :state_id, :city_id, :organization, :location, :description, :cost, :currency_id, :camp_website, :start_date, :end_date, :upload, :member_profile_id, :created_at, :updated_at],
        include: {
            sports: {
                only: [:id, :name, :image_url]
            }
        }
    )

    events_array = []
    events_array << event

    { events: events_array }.as_json
  end

  def self.show_event(data, current_user)
    begin
      data  = data.with_indifferent_access
      event = Event.find_by_id(data[:event][:id])
      resp_data       = event_response(event)
      resp_status     = 1
      resp_message    = 'Event details'
      resp_errors     = ''
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
