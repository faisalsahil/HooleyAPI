class Api::V1::RolesController < ApplicationController

  def index
    resp_data = Role.get_roles
    render json: resp_data
  end

end
