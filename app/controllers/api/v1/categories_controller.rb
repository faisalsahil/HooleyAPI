class Api::V1::CategoriesController < Api::V1::ApiProtectedController
  
  # Calling from web and app
  def index
    # params = {
    #   "auth_token": "111111111",
    # }
    user_session = UserSession.find_by_auth_token(params[:auth_token])
    if user_session.present?
      resp_data = Category.get_categories(params, user_session.user)
      render json: resp_data
    else
      resp_data = {resp_data: {}, resp_status: 0, resp_message: 'Invalid Token', resp_error: 'error'}.as_json
      return render json: resp_data
    end
  end
  
  # calling from web
  def create
    category = Category.new(category_params)
    category.save!
    resp_data    = {}
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  # calling from web
  def edit
    category = Category.find_by_id(params[:id])
    resp_data    = {category: category}.as_json
    resp_status  = 1
    resp_message = 'Success'
    resp_errors  = ''
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end

  # calling from web
  def update
    category = Category.find_by_id(params[:id])
    category.name = params[:name]
    if category.save
      resp_data    = {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    else
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'Category not updated.'
      common_api_response(resp_data, resp_status, resp_message, resp_errors)
    end
  end
  
  # calliing from web
  def destroy
    category = Category.find_by_id(params[:id])
    if category.present?
      if category.is_deleted
        category.is_deleted = false
      else
        category.is_deleted = true
      end
      category.save!
      resp_data    = {}
      resp_status  = 1
      resp_message = 'Success'
      resp_errors  = ''
    else
      resp_data    = {}
      resp_status  = 0
      resp_message = 'error'
      resp_errors  = 'Category not found'
    end
    common_api_response(resp_data, resp_status, resp_message, resp_errors)
  end
  
  private
  def category_params
    params.require(:category).permit(:name)
  end
end
