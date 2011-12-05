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

  def test_edit
    get :edit, :id => posts(:one)
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:post)
  end

  def test_update_invalid
    put :update, :id => posts(:one), :post => {:title => ''}
    assert_not_nil assigns(:post)
    assert_response :success
    assert_template 'edit'
  end

  def test_update_valid
    Post.any_instance.stubs(:valid?).returns(true)
    put :update, :id => posts(:one)
    assert_redirected_to post_url(assigns(:post))
  end

end
