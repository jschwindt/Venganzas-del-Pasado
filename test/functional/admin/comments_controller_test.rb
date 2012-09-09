require 'test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "index" do
    get :index
    assert_response :success
    assert_template 'index'
  end

end
