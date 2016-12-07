class Synchronization < ApplicationRecord
  belongs_to :member_profile

  @@limit =2

  # def self.db_sync(data, current_user, sync_id=nil)
  #   data = data.with_indifferent_access
  #   member_type = data[:synchronization][:sync_type]
  #   data[:synchronization][:synced_date] ? synced_date = data[:synchronization][:synced_date] : synced_date = Time.now
  #   profile = current_user.profile
  #
  #   if member_type == 'FOLLOWERS'
  #     members_followers = MemberFollowing.where("following_profile_id = ?", profile.id)
  #     members_followers = members_followers.where("updated_at < ?", synced_date)
  #     members_followers = members_followers.order("created_at DESC")
  #     paging_records = members_followers
  #     members_followers = members_followers.limit(@@limit)
  #   elsif member_type == 'FOLLOWINGS'
  #     members_followings = profile.member_followings
  #     members_followings = members_followings.where("updated_at < ?", synced_date)
  #     members_followings = members_followings.order("created_at DESC")
  #     paging_records             = members_followings
  #     members_followings = members_followings.limit(@@limit)
  #   elsif member_type == 'POSTS'
  #     following_ids = profile.member_followings.where(following_status: "accepted").pluck(:following_profile_id)
  #     posts  = Post.where("member_profile_id = ? OR member_profile_id IN (?) OR is_deleted = ?", profile.id, following_ids, false)
  #     posts  = posts.where("updated_at < ?", synced_date)
  #     posts  = posts.order("created_at DESC")
  #     paging_records = posts
  #     posts = posts.limit(@@limit)
  #   end
  #
  #   if members_followers.present?
  #     response = create_sync(profile, members_followers, "Member Followers", paging_records, data[:request_id])
  #   elsif members_followings.present?
  #     response = create_sync(profile, members_followings, "Member Followings", paging_records, data[:request_id])
  #   elsif posts.present?
  #     response = create_sync(profile, posts, "Member Followings", paging_records, data[:request_id])
  #   end
  # end
  #
  # def self.create_sync(profile, members, message, paging_records, request_id)
  #   response = make_sync_response(profile, members, request_id, message, paging_records)
  # end
  #
  # def self.destroy_sync_object(data, current_user)
  #   data = data.with_indifferent_access
  #   if data[:synchronization][:sync_token].present?
  #     sync_obj = Synchronization.find_by_sync_token(data[:synchronization][:sync_token])
  #     sync_obj.destroy! if sync_obj.present?
  #   end
  # end

  # Responses
  # def self.make_sync_response(profile, records, request_id, message, paging_records)
  #   paging_records       = paging_records.page(1).per_page(@@limit)
  #   paging_data = JsonBuilder.get_paging_data(1, @@limit, paging_records)
  #
  #   resp_data = sync_response(profile, records, message)
  #   resp_status = 1
  #   resp_request_id = request_id
  #   resp_message = message
  #   resp_errors = ''
  #   JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync", paging_data: paging_data)
  # end
  #
  def self.sync_response(profile, records, message)
    if message == "Posts"
      data  = Post.posts_array_response(records, profile)
    elsif message == "Member Followings"
      data = {
          members_followings: sync_members_followings_response(records)
      }
    elsif message == "Member Followers"
      data = {
          members_followers: sync_members_followings_response(records)
      }
    end
  end
  #
  # def self.empty_response(data, current_user)
  #   data = data.with_indifferent_access
  #   if data[:synchronization][:sync_type] == 'FOLLOWERS'
  #     message = 'members_followers'
  #   elsif data[:synchronization][:sync_type] == 'FOLLOWINGS'
  #     message = 'members_followings'
  #   elsif data[:synchronization][:sync_type] == 'POSTS'
  #     message = 'posts'
  #   end
  #   resp_data = {"#{message}" => []}
  #   resp_status = 0
  #   resp_request_id = data[:request_id]
  #   resp_message = 'No Record Found.'
  #   resp_errors = ''
  #   JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, type: "Sync")
  # end
  #
  def self.sync_members_followings_response(member_followings)
    member_followings.as_json(
        only: [:id, :member_profile_id, :following_profile_id, :following_status, :created_at, :updated_at],
        include: {
            member_profile: {
                only: [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name, :email]
                    },
                    role: {
                        only: [:id, :name]
                    }
                }
            }
        }
    )
  end
end

# == Schema Information
#
# Table name: synchronizations
#
#  id                :integer          not null, primary key
#  member_profile_id :integer
#  sync_token        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  synced_date       :datetime
#  sync_type         :string
#
