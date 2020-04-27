require 'test_helper'

class AdminCommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'redirect to login if logged out' do
    get admin_comments_url
    assert_redirected_to new_user_session_url
  end

  test 'denied access to plain users' do
    sign_in users(:one)
    get admin_comments_url
    assert_response 403
  end

  test 'show comments to admins, editors and moderators' do
    sign_in users(:admin)
    get admin_comments_url
    assert_response :success

    sign_in users(:editor)
    get admin_comments_url
    assert_response :success

    sign_in users(:moderator)
    get admin_comments_url
    assert_response :success
  end

  test 'should approve comment' do
    sign_in users(:moderator)
    get approve_admin_comment_url(comments(:pending))
    assert_equal flash[:notice], 'Se ha aprobado el comentario.'
    assert_redirected_to admin_comments_url(has_status: 'pending')
  end

  test 'should trach comment' do
    sign_in users(:moderator)
    delete trash_admin_comment_url(comments(:pending))
    assert_equal flash[:notice], 'Se ha eliminado el comentario.'
    assert_redirected_to admin_comments_url
  end

  test 'should destroy comment' do
    sign_in users(:admin)
    delete admin_comment_url(comments(:pending))
    assert_equal flash[:notice], 'Se ha eliminado definitivamente el comentario.'
    assert_redirected_to admin_comments_url(has_status: 'deleted')
  end
end
