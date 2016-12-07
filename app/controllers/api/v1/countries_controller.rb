class Api::V1::CountriesController < Api::V1::ApiProtectedController

  def index
    resp_data = Country.get_countries
    render json: resp_data
  end

  def city_list
    # cities          = City.where(country_id: params[:country_id])
    cities          = City.all
    resp_data       = {cities: cities}.as_json
    resp_status     = 1
    resp_message    = 'Country city list'
    resp_errors     = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def state_list
    # states          = State.where(country_id: params[:country_id])
    states          = State.all
    resp_data       = {states: states}.as_json
    resp_status     = 1
    resp_message    = 'Country state list'
    resp_errors     = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  def currency_list
    currencies      = Currency.all
    resp_data       = {currencies: currencies}.as_json
    resp_status     = 1
    resp_message    = 'Currency List'
    resp_errors     = ''

    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

end
