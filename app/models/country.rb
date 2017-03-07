class Country < ApplicationRecord
  
  has_many :member_profiles
  has_many :cities
  
  validates_presence_of :country_name, presence: true
  

  def self.get_countries(data=nil)
    countries = Country.all
    resp_data = response_countries_list(countries)

    resp_status     = 1
    resp_request_id = data[:request_id] if data && data[:request_id].present?
    resp_message    = 'Countries'
    resp_errors     = ''
    JsonBuilder.json_builder(resp_data, resp_status, resp_message, resp_request_id, errors: resp_errors)
  end

  def self.response_countries_list(countries)
    countries = countries.as_json(
        only: [:id, :country_name, :iso],
        include:{
            cities: {
                only:[:id, :name, :code]
            }
        }
    )

    {countries: countries}.as_json
  end
end

# == Schema Information
#
# Table name: countries
#
#  id           :integer          not null, primary key
#  country_name :string
#  iso          :string
#  iso2         :string
#  iso3         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
