require 'test_helper'

class BannerTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: banners
#
#  id            :integer          not null, primary key
#  title         :string
#  alt_text      :string
#  url           :string
#  detail        :text
#  path          :string
#  from_date     :datetime
#  to_date       :datetime
#  active        :boolean
#  default_photo :boolean
#  show_at_home  :boolean
#  sequence      :integer
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
