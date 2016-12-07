class Api::V1::SportsController < Api::V1::ApiProtectedController

  def index
    resp_data = Sport.sport_list( params)
    return render json: resp_data
  end

  def create
    resp_data = Sport.sport_create(params)
    return render json: resp_data
  end

  def show
    sport = Sport.find_by_id(params[:id])
    if sport.present?
      sport = sport.as_json(
          only: [:id,:name, :image_url,:created_at]

      )

      resp_data    = sport

      render json: resp_data
    end
  end

  def edit
    sport = Sport.find_by_id(params[:id])
    if sport.present?
      sport = sport.as_json(
          only: [:id,:name, :image_url,:created_at]

      )

      resp_data    = sport

      render json: resp_data

    end
  end

  def update
    @sport = Sport.find_by_id(params[:id])
    sport = @sport.update(params.require(:sport).permit(:name,:image_url))
    if sport.present?
      resp_data    = sport
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def destroy
    sport = Sport.find_by_id(params[:id])
    if sport.present?
      sport.destroy
      resp_data    = ''
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end

  def sport_position_list
    # sport_positions = SportPosition.where(sport_id: params[:sport_id])
    sport_positions = SportPosition.all
    resp_data       = {sport_positions: sport_positions}.as_json
    resp_status     = 1
    resp_message    = 'Sport positions list'
    resp_errors     = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

end
