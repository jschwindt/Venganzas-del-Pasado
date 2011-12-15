require 'test_helper'

class PostsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:editor)
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:posts)
  end

  def test_show
    get :show, :id => posts(:one)
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:post)
  end

end
