module CommonApiResponse
  def common_api_response(resp_data)
    format.json { render json: resp_data }
    format.xml { render xml: resp_data }
  end
end