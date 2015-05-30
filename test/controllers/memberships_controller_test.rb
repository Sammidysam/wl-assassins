require 'test_helper'

class MembershipsControllerTest < ActionController::TestCase
  test "should get respond" do
    get :respond
    assert_response :success
  end

end
