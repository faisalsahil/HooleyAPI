# user_profile               = MemberProfile.create!(country_id: 1, city_id: 1)
# user                       = user_profile.build_user
# user.first_name            = "test"
# user.last_name             = "test"
# user.email                 = "test@gmail.com"
# user.password              = "test123456"
# user.password_confirmation = "test123456"
# user.save!
#
# 10.times {
#   post                     = Post.create!(member_profile_id: user_profile.id, post_title: "Just Testing", post_description: "testing", latitude: 3343.444, longitude: 2323.2323, location: "Atlanta", is_post_public: true)
#   post_video               = post.post_videos.build
#   post_video.video_url     = "fusseo-posts/8/android/20160701121342/c3d622da-8afb-4067-93be-7db7ce010b3d/video/video.mp4"
#   post_video.thumbnail_url = "http://media3.giphy.com/media/mlBDoVLOGidEc/giphy.gif"
#   post_video.save!
# }
#
# @countries = Country.all
#
# if @countries.blank?
#   url       = "https://restcountries.eu/rest/v1/all"
#   response  = HTTParty.get(URI.encode(url))
#   countries = []
#   response.each do |country|
#     county              = Country.new
#     county.country_name = country['name']
#     county.iso          = country['alpha2Code']
#     county.iso2          = country['alpha2Code']
#     countries << county
#   end
#
#   Country.import countries
# end

occupations           = ['Agriculture', 'Agriculture & planning', 'Art & design', 'Biological sciences', 'Building/grounds cleaninng & maintenance', 'Business', 'Community & social services', 'Computers/IT/Mathematics', 'Construction/Installation/ Repair', 'Education & Training', 'Engineering', 'Entertainer/performer', 'Environmental sciences', 'Finance', 'Food prep/Serving', 'Health care practitioner/Technition', 'Laguages/Literature', 'Legal', 'Liberal Arts', 'Managemnt', 'Mechanics & repair', 'Media & communication', 'Military sciences', 'Office/administrative support', 'Other', 'Personal care & services', 'Philosophy & religion', 'Physical Sciences', 'Production & manufacturing', 'Protective services', 'Psycology & counseling', 'Recretion & fitness', 'Sales', 'Social sciences', 'Transportation']
relationship_statuses = ['In a relationShip', 'Its complicated', 'Married', 'Single']
political_views       = ['Conservative', 'Democrate', 'Independent',	'Liberal', 'Libertarian', 'Moderate', 'Other', 'Republican']
religions             = ['Agnostic',	'Atheist',	'Buddhism',	'Christianity',	'Hinduism',	'Islam', 'Judaism',	'New age', 'Other','Spiritual']
languages             = ['Arabic', 'Chinese', 'English', 'French', 'Hindi', 'German', 'Italian', 'Japanese', 'Other', 'Portuguese', 'Russian', 'Spanish']
college_majors        = ['Agriculture', 'Agriculture & planning', 'Arts', 'Biological sciences', 'Business', 'Communications', 'Computer/Information services', 'Health care', 'Social services']
ethnic_backgrounds    = ['Asian american', 'Black or African american', 'European american' ,'Native american or Alska native', 'Native hawaiians or other pacific islander', 'White american']

languages.each do |lang|
  Language.create!(name: lang)
end

college_majors.each do |colg|
  CollegeMajor.create!(name: colg)
end

ethnic_backgrounds.each do |ethn|
  EthnicBackground.create!(name: ethn)
end

occupations.each do |occu|
  Occupation.create!(name: occu)
end

relationship_statuses.each do |rel|
  RelationshipStatus.create!(name: rel)
end

political_views.each do |polit|
  PoliticalView.create!(name: polit)
end

religions.each do |relg|
  Religion.create!(name: relg)
end


Category.create!(name: 'hooley', is_deleted: true)


