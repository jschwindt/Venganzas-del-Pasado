require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test 'should search posts' do
    get search_url q: 'one'
    assert_response :success
  end

  test 'should search comments' do
    get search_url q: 'one', what: 'comments'
    assert_response :success
  end

  test 'should search texts' do
    get search_url q: 'one', what: 'texts',
                   date_from: { year: 2019, month: 1 }, date_to: { year: 2020, month: 12 }
    assert_response :success
  end
end
