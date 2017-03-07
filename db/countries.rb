@countries = Country.all

if @countries.blank?
  url       = "https://restcountries.eu/rest/v1/all"
  response  = HTTParty.get(URI.encode(url))
  countries = []
  response.each do |country|
    county              = Country.new
    county.country_name = country['name']
    county.iso          = country['alpha2Code']
    countries << county
  end

Country.import countries
end