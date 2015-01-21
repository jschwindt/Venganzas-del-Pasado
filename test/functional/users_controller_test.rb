require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "should show users profile with comments" do
    user = users(:one)
    get :show, :id => user.id
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:user)
    assert_not_nil assigns(:objects)
  end

end
