require 'test_helper'

class TorrentsControllerTest < ActionDispatch::IntegrationTest
  test 'should get torrents' do
    get torrents_url
    assert_response :success
  end
end
