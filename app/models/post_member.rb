class PostMember < ApplicationRecord
  belongs_to :post
  belongs_to :member_profile
  validates_uniqueness_of :post_id, scope: :member_profile_id

  @@limit = 10

  def self.post_members_list(data, current_user)
    data     = data.with_indifferent_access
    per_page = (data[:per_page] || @@limit).to_i
    page     = (data[:page] || 1).to_i

    post = Post.find_by_id(data[:post][:id])

    post_members = post.post_members
    if post_members

      post_members = post_members.page(page.to_i).per_page(per_page.to_i)
      paging_data  = JsonBuilder.get_paging_data(page, per_page, post_members)

      resp_data       = posts_members_response(post_members)
      resp_status     = 1
      resp_request_id = data[:request_id]
      resp_message    = 'Post Members'
      resp_errors     = ''
    else
      resp_data       = ''
      resp_request_id = data[:request_id]
      resp_status     = 0
      resp_message    = 'Errors'
      resp_errors     = 'Post Does not exist'

    end

    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors, paging_data: paging_data)
  end

  private
  def self.posts_members_response(post_member_array)
    post_member_array.as_json(
        only:    [:id],
        include: {
            member_profile: {
                only:    [:id, :photo, :country_id, :is_profile_public, :gender],
                include: {
                    user: {
                        only: [:id, :first_name, :last_name]
                    }
                }
            }
        },
        root: "post_members"
    )
  end
end

# == Schema Information
#
# Table name: post_members
#
#  id                :integer          not null, primary key
#  post_id           :integer
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
