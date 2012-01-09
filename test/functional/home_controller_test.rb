require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert assigns(:posts)
    assert assigns(:comments)
    assert_template 'index'
    assert_response :success
  end

end
