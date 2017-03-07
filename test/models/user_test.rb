require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
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
