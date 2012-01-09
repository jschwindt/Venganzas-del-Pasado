require 'test_helper'
require 'thinking_sphinx/test'
ThinkingSphinx::Test.init

class SearchControllerTest < ActionController::TestCase
  test "should get index" do
    ThinkingSphinx::Test.run do
      get :index
      assert assigns(:what)
      assert assigns(:results)
      assert assigns(:facets)
      assert_response :success
    end
  end

end
