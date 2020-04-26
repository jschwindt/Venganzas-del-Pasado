require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test 'should show article' do
    get article_url articles(:with_html)
    assert_response :success
  end
end
