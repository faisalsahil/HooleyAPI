class Api::V1::SportPositionsController < Api::V1::ApiProtectedController
  def index
    resp_data = SportPosition.sport_position_list( params)
    return render json: resp_data
  end


  def create
    resp_data = SportPosition.sport_position_create(params)
    return render json: resp_data
  end


  def show
    sport_position = SportPosition.find_by_id(params[:id])
    if sport_position.present?
      sport_position = sport_position.as_json(
          only: [:id,:sport_id, :name,:created_at]

      )

      resp_data    = sport_position

      render json: resp_data
    end
  end

  def destroy
    sport_position = SportPosition.find_by_id(params[:id])
    if sport_position.present?
      sport_position.destroy
      resp_data    = ''
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end

  end

  def edit
    sport_position = SportPosition.find_by_id(params[:id])
    if sport_position.present?
      sport_position = sport_position.as_json(
          only: [:id,:name, :created_at, :sport_id]

      )

      resp_data    = sport_position

      render json: resp_data

    end
  end

  def update
    @sport_position = SportPosition.find_by_id(params[:id])
    sport_position = @sport_position.update(params.require(:sport_position).permit(:name,:sport_id))
    if sport_position.present?
      resp_data    = sport_position
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end


end
