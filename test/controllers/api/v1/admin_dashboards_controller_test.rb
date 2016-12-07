require 'test_helper'

class Api::V1::AdminDashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_admin_dashboards_index_url
    assert_response :success
  end

end
