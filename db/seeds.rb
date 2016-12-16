user_profile               = MemberProfile.create!(about: "I'm admin", country_id: 1, city_id: 1)
user                       = user_profile.build_user
user.first_name            = "test"
user.last_name             = "test"
user.email                 = "test@gmail.com"
user.password              = "test123456"
user.password_confirmation = "test123456"
user.save!

10.times {
  post                     = Post.create!(member_profile_id: user_profile.id, post_title: "Just Testing", post_description: "testing", latitude: 3343.444, longitude: 2323.2323, location: "Atlanta", is_post_public: true)
  post_video               = post.post_videos.build
  post_video.video_url     = "fusseo-posts/8/android/20160701121342/c3d622da-8afb-4067-93be-7db7ce010b3d/video/video.mp4"
  post_video.thumbnail_url = "http://media3.giphy.com/media/mlBDoVLOGidEc/giphy.gif"
  post_video.save!
}

@countries = Country.all

if @countries.blank?
  url       = "https://restcountries.eu/rest/v1/all"
  response  = HTTParty.get(URI.encode(url))
  countries = []
  response.each do |country|
    county              = Country.new
    county.country_name = country['name']
    county.iso          = country['alpha2Code']
    county.iso2          = country['alpha2Code']
    countries << county
  end
  
  Country.import countries
end