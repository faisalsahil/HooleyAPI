class UserAlbum < ApplicationRecord
  belongs_to :member_profile
  has_many :album_images
  accepts_nested_attributes_for :album_images

  @@limit = 10

  def album_images_count
    self.album_images.count
  end

  def self.create_album(data, current_user)
    begin
      data = data.with_indifferent_access
      profile = current_user.profile
      album = profile.user_albums.build(data[:album])
      if album.save
        resp_data   = album
        resp_status = 1
        resp_message = 'Album Created'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = album.errors.messages
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.edit_album(data, current_user)
    begin
      data = data.with_indifferent_access
      profile = current_user.profile
      album = profile.user_albums.find_by_id(data[:album][:id])
      if album.present?
        album.update_attributes(data[:album])
        album.save
        resp_data   = album
        resp_status = 1
        resp_message = 'Album Updated'
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Album not found'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      paging_data     = ''
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    response = JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.album_list(data, current_user)
    begin
      data = data.with_indifferent_access

      profile     = current_user.profile
      albums      = profile.user_albums

      resp_data = album_array_response(albums)
      resp_status = 1
      resp_message = 'Album List'
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

  def self.show_album(data, current_user)
    begin
      data = data.with_indifferent_access

      per_page     = (data[:per_page] || @@limit).to_i
      page         = (data[:page] || 1).to_i

      album        = UserAlbum.find_by_id(data[:album][:id])
      album_images = album.album_images

      album_images = album_images.page(page.to_i).per_page(per_page.to_i)
      paging_data  = JsonBuilder.get_paging_data(page, per_page, album_images)

      if album.present?
        resp_data = album_response(album, album_images)
        resp_status = 1
        resp_message = 'Album '
        resp_errors = ''
      else
        resp_data = ''
        resp_status = 0
        resp_message = 'Errors'
        resp_errors = 'Album not found.'
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

  def self.add_images_to_album(data, current_user)
    begin
      data = data.with_indifferent_access

      per_page     = (data[:per_page] || @@limit).to_i
      page         = (data[:page] || 1).to_i

      album = UserAlbum.find_by_id(data[:album][:id])
      album.album_images.build(data[:album][:album_images_attributes])

      if album.save
        album_images = album.album_images
        album_images = album_images.page(page.to_i).per_page(per_page.to_i)
        paging_data  = JsonBuilder.get_paging_data(page, per_page, album_images)

        resp_data    = album_response(album, album_images)
        resp_status  = 1
        resp_message = 'Upload Successful '
        resp_errors  = ''
      else
        resp_data    = ''
        resp_status  = 0
        resp_message = 'Error'
        resp_errors  = album.errors.messages
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

  def self.album_response(album, album_images)
    album_images_array = []
    album_images && album_images.each do |album_image|
      if album_image.post_attachment_id != nil
        album_images_array << {
          id:                    album_image.id,
          attachment_url:        album_image.attachment_url,
          thumbnail_url:         album_image.thumbnail_url,
          created_at:            album_image.created_at,
          updated_at:            album_image.updated_at,
          attachment_dimensions: [],
          attachment_tags:       album_image.try(:post_attachment).try(:post_photo_users)
        }
      elsif album_image.post_id != nil
        album_images_array << {
          id:                    album_image.id,
          attachment_url:        album_image.attachment_url,
          thumbnail_url:         album_image.thumbnail_url,
          created_at:            album_image.created_at,
          updated_at:            album_image.updated_at,
          attachment_dimensions: album_image.try(:post),
          attachment_tags:       []
        }
      else
        album_images_array << {
            id:                    album_image.id,
            attachment_url:        album_image.attachment_url,
            thumbnail_url:         album_image.thumbnail_url,
            created_at:            album_image.created_at,
            updated_at:            album_image.updated_at,
            attachment_dimensions: [],
            attachment_tags:       []

        }
      end
    end
    album = {
        id:               album.id,
        name:             album.name,
        album_photo_url:  album.album_photo_url,
        default_album:    album.default_album,
        album_images:     album_images_array,
        created_at:       album.created_at,
        updated_at:       album.updated_at
    }
    {"album": album}.as_json
  end

  def self.album_array_response(albums)
    albums = albums.as_json(
       only: [:id, :name, :album_photo_url, :default_album, :created_at, :updated_at],
       methods:[:album_images_count]
    )
    {"albums": albums}.as_json
  end

end

# == Schema Information
#
# Table name: user_albums
#
#  id                :integer          not null, primary key
#  name              :string
#  status            :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  member_profile_id :integer
#  album_photo_url   :string
#  default_album     :boolean          default(FALSE)
#
