require 'test_helper'

class AdminUsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'redirect to login if logged out' do
    get admin_users_url
    assert_redirected_to new_user_session_url
  end

  test 'denied access to non admins' do
    sign_in users(:one)
    get admin_users_url
    assert_response 403

    sign_in users(:editor)
    get admin_users_url
    assert_response 403

    sign_in users(:moderator)
    get admin_users_url
    assert_response 403
  end

  test 'show users to admins' do
    sign_in users(:admin)
    get admin_users_url
    assert_response :success
  end

  test 'should show edit form' do
    sign_in users(:admin)
    get edit_admin_user_url(users(:one))
    assert_response :success
  end

  test 'should update user' do
    sign_in users(:admin)
    user = users(:one)
    patch admin_user_url(user), params: { user: { role: 'editor' } }
    assert_equal flash[:notice], 'Se han guardado los cambios.'
    assert_redirected_to edit_admin_user_url(user)
  end
end
