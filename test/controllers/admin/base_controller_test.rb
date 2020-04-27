require 'test_helper'

class BaseUsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'redirect to login if logged out' do
    get admin_dashboard_url
    assert_redirected_to new_user_session_url
  end

  test 'denied access to non admins' do
    sign_in users(:one)
    get admin_dashboard_url
    assert_response 403
  end

  test 'show dashboard to editors, moderators and admins' do
    sign_in users(:editor)
    get admin_dashboard_url
    assert_response :success

    sign_in users(:moderator)
    get admin_dashboard_url
    assert_response :success

    sign_in users(:admin)
    get admin_dashboard_url
    assert_response :success
  end
end
