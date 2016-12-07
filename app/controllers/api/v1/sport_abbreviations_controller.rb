class Api::V1::SportAbbreviationsController < Api::V1::ApiProtectedController

  def index
    resp_data = SportAbbreviation.sport_abbreviation_list( params)
    return render json: resp_data
  end

  def create
    resp_data = SportAbbreviation.sport_abbreviation_create(params)
    return render json: resp_data
  end

  def show
    sport_abbreviation = SportAbbreviation.find_by_id(params[:id])
    if sport_abbreviation.present?
      sport_abbreviation = sport_abbreviation.as_json(
          only: [:id,:sport_id, :title,:description,:image_url,:created_at]

      )

      resp_data    = sport_abbreviation

      render json: resp_data
    end
  end

  def destroy
    sport_abbreviation = SportAbbreviation.find_by_id(params[:id])
    if sport_abbreviation.present?
      sport_abbreviation.destroy
      resp_data    = ''
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end

  end

  def edit
    sport_abbreviation = SportAbbreviation.find_by_id(params[:id])
    if sport_abbreviation.present?
      sport_abbreviation = sport_abbreviation.as_json(
          only: [:id,:title, :description,:sport_id ,:created_at, :image_url]

      )

      resp_data    = sport_abbreviation

      render json: resp_data

    end
  end

  def update
    @sport_abbreviation = SportAbbreviation.find_by_id(params[:id])
    sport_abbreviation = @sport_abbreviation.update(params.require(:sport_abbreviation).permit(:title,:description,:sport_id ,:image_url))
    if sport_abbreviation.present?
      resp_data    = sport_abbreviation
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end


end
