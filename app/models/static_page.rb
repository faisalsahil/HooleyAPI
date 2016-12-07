class StaticPage < ApplicationRecord
end

# == Schema Information
#
# Table name: static_pages
#
#  id               :integer          not null, primary key
#  title            :string
#  content          :text
#  page_keyword     :text
#  page_description :text
#  content_for      :string
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
