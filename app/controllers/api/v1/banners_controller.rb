class Api::V1::BannersController < Api::V1::ApiProtectedController

  def index
    resp_data = Banner.banner_list( params)
    return render json: resp_data
  end

  def create
    resp_data = Banner.banner_create(params)
    return render json: resp_data
  end

  def show
    banner = Banner.find_by_id(params[:id])
    if banner.present?
      banner = banner.as_json(
          only: [:id,:title, :url,:created_at]

      )

      resp_data    = banner

      render json: resp_data
    end
  end

  def destroy
    banner = Banner.find_by_id(params[:id])
    if banner.present?
      banner.destroy
      resp_data    = ''
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end


  def edit
    banner = Banner.find_by_id(params[:id])
    if banner.present?
      banner = banner.as_json(
          only: [:id,:title, :url,:created_at]

      )

      resp_data    = banner

      render json: resp_data

    end
  end

  def update
    @banner = Banner.find_by_id(params[:id])
    banner = @banner.update(params.require(:banner).permit(:title,:url))
    if banner.present?
      resp_data    = banner
      resp_status  = 1
      resp_message = 'success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end



end
