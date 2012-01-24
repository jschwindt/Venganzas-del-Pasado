require 'test_helper'

class BasicNavigationTest < ActionDispatch::IntegrationTest

  test "home" do
    get "/"
    assert_response :success
  end

end