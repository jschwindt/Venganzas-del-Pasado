require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert assigns(:posts)
    assert assigns(:comments)
    assert_template 'index'
    assert_response :success
  end

  test "should switch player" do
    get :switch_player
    assert cookies.has_key?(:player)
    assert_redirected_to root_url
  end

end
