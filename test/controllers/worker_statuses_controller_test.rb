require 'test_helper'

class WorkerStatusesControllerTest < ActionController::TestCase
  test "should get create" do
    get :create
    assert_response :success
  end

end
