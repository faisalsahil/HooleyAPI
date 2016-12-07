class Api::V1::AccountsController < ApplicationController

  def index
    resp_data = Account.get_account_list
    render json: resp_data
  end
end
