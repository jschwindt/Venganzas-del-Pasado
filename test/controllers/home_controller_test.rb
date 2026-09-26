require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should get home" do
    get root_url
    assert_response :success
    assert_select "a[href=?]", new_user_session_path, text: "Iniciá sesión"
    assert_select ".navbar-end > a.navbar-item img", count: 0
  end

  test "should get home logged in" do
    sign_in users(:one)
    get root_url
    assert_response :success
  end
end
