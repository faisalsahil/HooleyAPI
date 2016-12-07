# Be sure to restart your server when you modify this file. Action Cable runs in a loop that does not support auto reloading.
class ProfileChannel < ApplicationCable::Channel

  def subscribed
    if current_user.present?
      stream_from "profile_channel_#{current_user.id}"
    else
      current_user = find_verified_user
      stream_from "profile_channel_#{current_user.id}"
    end
  end

  def unsubscribed
    stop_all_streams
  end

  def account_update(data)
    response = MemberProfile.account_update(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def update(data)
    response = MemberProfile.update(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def reset_password(data)
    response = User.reset_password(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def get_profile(data)
    response = MemberProfile.get_profile(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def logout(data)
    response = User.log_out(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def update_uuid(data)
    response = UserSession.update_uuid(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def search_member(data)
    response = MemberFollowing.search_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def follow_member(data)
    response = MemberFollowing.follow_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def unfollow_member(data)
    response = MemberFollowing.unfollow_member(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def accept_follower(data)
    response = MemberFollowing.accept_follower(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def reject_follower(data)
    response = MemberFollowing.reject_follower(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def get_following_requests(data)
    response = MemberFollowing.get_following_requests(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def get_following_members(data)
    response = MemberFollowing.get_following_members(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def get_followers(data)
    response = MemberFollowing.get_followers(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def group_create(data)
    response = MemberGroup.group_create(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def group_show(data)
    response = MemberGroup.group_show(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def group_destroy(data)
    response = MemberGroup.group_destroy(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def group_update(data)
    response = MemberGroup.group_update(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def add_member_to_group(data)
    response = MemberGroup.add_member_to_group(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def group_index(data)
    response = MemberGroup.group_index(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def image_upload(data)
    response = MemberProfile.image_upload(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def other_member_profile(data)
    response = MemberProfile.other_member_profile(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def create_message(data)
    response = Message.create_message(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def show_inbox(data)
    response = Message.show_inbox(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def auto_complete_followers(data)
    response = MemberProfile.auto_complete_followers(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def add_sport_abbreviations(data)
    response = MemberProfile.add_sport_abbreviations(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def user_list(data)
    response = MemberProfile.user_list(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def sports_data(data)
    response = MemberProfile.sports_data(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def country_data(data)
    response = MemberProfile.country_data_list(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def filters_data(data)
    response = MemberProfile.filters_data(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def event_create(data)
    response = Event.event_create(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def event_search(data)
    response = Event.event_search(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def search(data)
    response = MemberProfile.search(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  # def event_list(data)
  #   response = Event.event_list(data, current_user)
  #   ProfileJob.perform_later response, current_user.id
  # end

  def show_event(data)
    response = Event.show_event(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def attend_event(data)
    response = AttendedEvent.attend_event(data, current_user)
    ProfileJob.perform_later response, current_user.id
  end

  def roles(data)
    response = Role.get_roles(data)
    ProfileJob.perform_later response, current_user.id
  end

  protected
  def find_verified_user
    user_session = UserSession.find_by_auth_token(params[:auth_token])

    if user_session.present?
      user_session.user
    else
      reject_unauthorized_connection
    end
  end
end