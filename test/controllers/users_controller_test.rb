require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'show user sign_in, sign_up, etc' do
    get new_user_session_url
    assert_response :success

    get new_user_registration_url
    assert_response :success

    get new_user_password_url
    assert_response :success

    get new_user_confirmation_url
    assert_response :success

    get new_user_unlock_url
    assert_response :success
  end

  test 'should show user' do
    get user_url users(:one)
    assert_response :success
  end

  test 'should redirect to user FriendlyId' do
    user = users(:one)
    get user_url user.id
    assert_redirected_to user_url(user)
  end

  test 'should show users comments' do
    get comments_user_url users(:one)
    assert_response :success
  end

  test 'should show users contributions' do
    get contributions_user_url users(:one)
    assert_response :success
  end
end
