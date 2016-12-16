class MemberGroup < ApplicationRecord
  
  has_many :member_group_contacts, dependent: :destroy
  belongs_to :member_profile
  
  accepts_nested_attributes_for :member_group_contacts
  
  validates_presence_of   :group_name, presence: true
  validates_uniqueness_of :group_name, scope: :member_profile_id
  
  @@limit = 10

  def response_member_group
    self.as_json(
        only:    [:id, :group_name],
        include: {
            member_group_contacts: {
                only:    [:id],
                include: {
                    member_profile: {
                        only:    [:id, :phone, :photo, :country_id, :gender, :dob],
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
  end

  def self.group_index(data, current_user)
    begin
      data     = data.with_indifferent_access
      per_page = (data[:per_page] || @@limit).to_i
      page     = (data[:page] || 1).to_i

      profile       = current_user.profile
      member_groups = profile.member_groups.where(is_deleted: false)
      if member_groups.present?
        member_groups = member_groups.page(page.to_i).per_page(per_page.to_i)
        paging_data   = JsonBuilder.get_paging_data(page, per_page, member_groups)

        resp_data = response_group_list(member_groups)

        resp_status     = 1
        resp_message    = 'Member Group List'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'No Group Found.'
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

  def self.group_create(data, current_user)
    begin
      data         = data.with_indifferent_access
      profile      = current_user.profile
      member_group = profile.member_groups.build(data[:member_group])
      if member_group.save
        resp_status     = 1
        resp_message    = 'Member Group Successfully created'
        resp_errors     = ''
        resp_data       = member_group.response_member_group
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = MemberProfile.error_messages(member_group)
      end
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

  def self.group_show(data, current_user)
    begin
      data = data.with_indifferent_access

      member_group = MemberGroup.find_by_id(data[:member_group][:id])
      if member_group.present?
        resp_data       = member_group.response_member_group
        resp_status     = 1
        resp_message    = 'Group Detail'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Error'
        resp_errors     = 'No Group Found.'
      end
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

  def self.group_destroy(data, current_user)
    begin
      data         = data.with_indifferent_access
      profile      = current_user.profile
      member_group = MemberGroup.find_by_id_and_member_profile_id(data[:member_group][:id], profile.id)
      if member_group.id != profile.default_group_id
        member_group.is_deleted = true
        member_group.save!
        resp_status     = 1
        resp_message    = 'Member Group Successfully Destroyed'
        resp_errors     = ''
        resp_data       = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'You can not destroy this group.'
      end
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

  def self.group_update(data, current_user)
    begin
      data         = data.with_indifferent_access
      profile      = current_user.profile
      member_group = MemberGroup.find_by_id_and_member_profile_id(data[:member_group][:id], profile.id)
      if member_group.present?
        member_group.update_attributes(data[:member_group])
        resp_data       = member_group.response_member_group
        resp_status     = 1
        resp_message    = 'Group has been updated'
        resp_errors     = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Error'
        resp_errors     = 'You are not authorized to update this group.'
      end
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

  def self.add_member_to_group(data, current_user)
    begin
      data = data.with_indifferent_access

      member_group = MemberGroup.find_by_id(data[:member_group][:id])
      member_group.update_attributes(data[:member_group])

      resp_data       = ''
      resp_status     = 1
      resp_message    = 'Group has been updated'
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

  def member_group_contacts_count
    self.member_group_contacts.count
  end

  private
  def self.response_group_list(member_groups_array)
    member_groups_array.as_json(
        only:    [:id, :group_name],
        include: {
            member_group_contacts: {
                only:    [:id],
                include: {
                    member_profile: {
                        only:    [:id, :photo, :country_id, :gender, :dob],
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
  end
end

# == Schema Information
#
# Table name: member_groups
#
#  id                :integer          not null, primary key
#  member_profile_id :integer
#  group_name        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  is_deleted        :boolean          default(FALSE)
#
