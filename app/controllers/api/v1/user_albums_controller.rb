class Api::V1::UserAlbumsController < ApplicationController

  # before_action :user_album_params, only:[:create]
  def index
    current_user = MemberProfile.find_by_id(params[:member_profile][:id]).user
    album_list   = UserAlbum.album_list(params, current_user)
    return render json: album_list
  end

  def show_album
    album_list   = UserAlbum.show_album(params, current_user)
    return render json: album_list
  end

  def create
    album   = UserAlbum.new(user_album_params)
    album.save!
    resp_data   = album
    resp_status = 1
    resp_message = 'Album Created'
    resp_errors = ''
    response    = JsonBuilder.json_builder(resp_data, resp_status, resp_message, errors: resp_errors)
    return render json: response
  end

  def add_image_to_album
    response = UserAlbum.add_images_to_album(params, current_user)
    return render json: response
  end

  private

  def user_album_params
    params.require(:user_album).permit(:name,:member_profile_id)
  end
end
