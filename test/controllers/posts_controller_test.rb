require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
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
end
