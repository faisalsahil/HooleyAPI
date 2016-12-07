class Report < ApplicationRecord
 belongs_to :reportable, polymorphic: true
 belongs_to :member_profile
 def self.report_post_response(reports, post)
  post = post.as_json(
      only:    [:id, :post_title, :post_description, :datetime, :post_datetime, :is_post_public, :post_type, :location, :latitude, :longitude],
      methods: [:likes_count, :comments_count, :post_members_counts],
      include: {
          member_profile: {
              only:    [:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
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
          },
          post_attachments: {
              only: [:id, :attachment_url, :thumbnail_url, :attachment_type],
              include:{
                  post_photo_users:{
                      only:[:id, :x_coordinate, :y_coordinate, :member_profile_id, :post_attachment_id],
                      include: {
                          member_profile: {
                              only: [:id],
                              include: {
                                  user: {
                                      only: [:id, :first_name, :last_name]
                                  }
                              }
                          }
                      }
                  }
              }
          }
      }
  )

  reports = reports.as_json(
       only: [:id, :comment],
       include:{
           member_profile: {
               only:[:id, :about, :phone, :photo, :country_id, :is_profile_public, :gender],
               include:{
                   user: {
                       only:[:id, :first_name, :last_name, :email],
                       include: {
                           role: {
                               only: [:id, :name]
                           }
                       }
                   }
               }
           }
       }
  )

  {post: post, reports: reports}.as_json
 end
end

# == Schema Information
#
# Table name: reports
#
#  id                :integer          not null, primary key
#  comment           :text
#  member_profile_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  reportable_id     :integer
#  reportable_type   :string
#
