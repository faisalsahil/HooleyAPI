class User < ApplicationRecord
  include JsonBuilder
  include Profile
  include AppConstants
  include PgSearch
  
  # after_create :send_email
  
  acts_as_token_authenticatable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, authentication_keys: [:login]
  
  has_many   :user_sessions
  has_many   :user_authentications, dependent: :destroy
  belongs_to :role
  belongs_to :profile, polymorphic: true
  
  accepts_nested_attributes_for :user_authentications
  attr_accessor :login
  scope :admin_profiles, -> { where(profile_type: 'AdminProfile') }

  validates_uniqueness_of :phone, allow_nil: true
  
  multisearchable against: [:first_name, :last_name, :email],
                  if: :published?

  pg_search_scope :search_by_title,
    against: [:first_name, :last_name, :email],
    using: {
        tsearch: {
            any_word: true,
            dictionary: "english"
        }
    }

  def published?
    true
  end

  def email_required?
    false
  end

  def self.sign_in(data)
    data = data.with_indifferent_access
    if data[:user][:email].present?
      user = User.find_by_email(data[:user][:email])
    else
      user = User.find_by_phone(data[:user][:phone])
    end
    device_type = data[:user_session][:device_type]
    if user && user.valid_password?(data[:user][:password])
      if user.profile_type == MEMBER && (device_type == DEVICE_IOS || device_type == DEVICE_ANDR || device_type == DEVICE_WEB) || (user.profile_type == ADMIN && device_type == DEVICE_WEB)

        user_sessions = UserSession.where("device_uuid = ? AND user_id != ?", data[:user_session][:device_uuid], user.id)
        user_sessions.destroy_all if user_sessions.present?
        user_session                = user.user_sessions.where(device_uuid: data[:user_session][:device_uuid]).try(:first) || user.user_sessions.build(data[:user_session])
        user_session.auth_token     = SecureRandom.hex(100)
        user_session.session_status = 'open'
        user_session.save!

        user.current_sign_in_at     = Time.now
        user.synced_datetime        = nil
        user.last_subscription_time = nil
        user.save!

        if user.profile_type == ADMIN
          resp_data = user.profile.admin_profile(user_session.auth_token)
        else
          resp_data = user.profile.member_profile(user_session.auth_token)
        end
        resp_status  = 1
        resp_message = 'User Profile'
        resp_errors  = ''
      else
        resp_data    = ''
        resp_status  = 0
        resp_message = 'Errors'
        resp_errors  = 'You are not allowed to sign in'
      end
    else
      resp_data    = ''
      resp_status  = 0
      resp_message = 'Errors'
      resp_errors  = 'Either your email or password is incorrect'
    end

    resp_request_id = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end
  
  def self.forgot_password(data)
    begin
      data = data.with_indifferent_access
      user = User.find_by_email(data[:user][:email])
      if user
        user.send_reset_password_instructions
        resp_status     = 1
        resp_message    = 'Please check your email and follow the instructions.'
        resp_errors     = ''
        resp_data       = ''
      else
        resp_data       = ''
        resp_status     = 0
        resp_message    = 'Errors'
        resp_errors     = 'User does not exist.'
      end
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.reset_password(data, current_user)
    begin
      data                     = data.with_indifferent_access
      is_success, user_session = UserSession.authenticate_session(data[:user_session][:token], data[:request_id])
      return user_session unless is_success
      user = user_session.user
      if user && user.valid_password?(data[:user][:password])
        user.password = data[:user][:new_password]
        user.save!
        resp_status     = 1
        resp_message    = 'Password Successfully Changed.'
        resp_errors     = ''
        resp_data       = ''
      else
        resp_status     = 0
        resp_message    = 'Error'
        resp_errors     = 'Your current password is incorrect.'
        resp_data       = ''
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

  def self.log_out(data, current_user)
    begin
      data         = data.with_indifferent_access
      user_session = UserSession.find_by_auth_token(data[:user_session][:token])
      if user_session.present?
        user_session.session_status = 'closed'
        user_session.save!
      end
      current_user.current_sign_in_at = nil
      current_user.synced_datetime    = nil
      current_user.save!
      resp_status     = 1
      resp_message    = 'Logout successful.'
      resp_errors     = ''
      resp_data       = ''
    rescue Exception => e
      resp_data       = ''
      resp_status     = 0
      resp_message    = 'error'
      resp_errors     = e
    end
    resp_request_id   = data[:request_id]
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def send_email
    UserMailer.registration_confirmation(email).deliver
  end

  def self.send_forgot_password_email(email)
    user = User.find_by_email(data[:user][:email])
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  profile_id             :integer
#  profile_type           :string
#  user_status            :string
#  authentication_token   :string
#  gender                 :string
#  banner_image_1         :string
#  banner_image_2         :string
#  banner_image_3         :string
#  promotion              :string
#  is_deleted             :boolean          default(FALSE)
#  last_subscription_time :datetime
#  synced_datetime        :datetime
#  first_name             :string
#  last_name              :string
#  retype_email           :string
#  role_id                :integer
#
