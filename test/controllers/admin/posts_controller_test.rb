require 'test_helper'

class AdminPostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'redirect to login if logged out' do
    get admin_posts_url
    assert_redirected_to new_user_session_url
  end

  test 'denied access to plain users and moderators' do
    sign_in users(:one)
    get admin_posts_url
    assert_response 403

    sign_in users(:moderator)
    get admin_posts_url
    assert_response 403
  end

  test 'show posts to admins and editors' do
    sign_in users(:admin)
    get admin_posts_url
    assert_response :success

    sign_in users(:editor)
    get admin_posts_url
    assert_response :success
  end

  test 'should show new form' do
    sign_in users(:editor)
    get new_admin_post_url
    assert_response :success
  end

  test 'should create post' do
    sign_in users(:editor)
    post admin_posts_url, params: {
      post: { status: 'draft', title: 'A Draft', created_at: DateTime.now }
    }
    assert_equal flash[:notice], 'Creado correctamente.'
    assert_response 302
  end

  test 'should show edit form' do
    sign_in users(:editor)
    get edit_admin_post_url(posts(:one))
    assert_response :success
  end

  test 'should update post' do
    sign_in users(:editor)
    post = posts(:one)
    patch admin_post_url(post), params: { post: { status: 'published' } }
    assert_equal flash[:notice], 'Se han guardado los cambios.'
    assert_redirected_to edit_admin_post_url(post)
  end

  test 'should approve contribution' do
    sign_in users(:admin)
    post = posts(:contributed)
    get approve_contribution_admin_post_url(post)
    assert_redirected_to post_url(post)
  end
end
