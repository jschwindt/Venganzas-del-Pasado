require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should get posts index' do
    get posts_url
    assert_response :success
  end

  test 'should show post' do
    get post_url posts(:published)
    assert_response :success
  end

  test 'should get archive' do
    get posts_archive_url year: 2010
    assert_response :success
  end

  test 'should get archive xhr' do
    get posts_archive_url(year: 2010), xhr: true
    assert_response :success
  end

  test 'should get contributions' do
    get contributions_url
    assert_response :success
  end

  test 'logged out new contribution should redirect to login' do
    get new_post_url
    assert_redirected_to new_user_session_url
  end

  test 'logged in contribution should show form' do
    sign_in users(:one)
    get new_post_url
    assert_response :success
  end

  test 'logged out create contribution should redirect to login' do
    post posts_url
    assert_redirected_to new_user_session_url
  end

  test 'logged in create contribution should fail' do
    sign_in users(:one)
    assert_no_difference 'Post.count' do
      post posts_url, params: { post: { title: '' } }
      assert_response :success
    end
  end

  test 'logged in create contribution should create' do
    sign_in users(:one)
    params = {
      post: {
        title: 'New Contribution',
        created_at: Date.new(2019, 1, 2),
        media_attributes: {
          '0' => {
            asset: Rack::Test::UploadedFile.new(
              Rails.root.join('test/fixtures/files', 'lavenganza_2015-01-02.mp3'), 'audio/mpeg'
            )
          }
        }
      }
    }
    assert_difference 'Post.count' do
      post posts_url, params: params
      assert_equal ActionMailer::Base.deliveries.first.subject, 'Hay una nueva contribución'
      assert_redirected_to new_post_url
    end
  end
end
