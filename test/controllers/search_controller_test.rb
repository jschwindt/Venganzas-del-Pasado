require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  def setup
    Searchkick.enable_callbacks
  end

  def teardown
    Searchkick.disable_callbacks
  end

  test 'should search posts' do
    get search_url q: 'one'
    assert_response :success
  end

  test 'should search comments' do
    get search_url q: 'one', what: 'comments'
    assert_response :success
  end
end
