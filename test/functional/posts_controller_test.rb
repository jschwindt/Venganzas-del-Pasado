require 'test_helper'

class PostsControllerTest < ActionController::TestCase
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

  def test_new
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:post)
  end

  def test_create_invalid
    Post.any_instance.stubs(:valid?).returns(false)
    post :create, :post => {}
    assert_response :success
    assert_not_nil assigns(:post)
    assert_template 'new'
  end

  def test_create_valid
    Post.any_instance.stubs(:valid?).returns(true)
    post :create, :post => { :title => 'test title' }
    assert_redirected_to post_url(assigns(:post))
  end

  def test_edit
    get :edit, :id => posts(:one)
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:post)
  end

  def test_update_invalid
    Post.any_instance.stubs(:valid?).returns(false)
    put :update, :id => posts(:one)
    assert_response :success
    assert_template 'edit'
    assert_not_nil assigns(:post)
  end

  def test_update_valid
    Post.any_instance.stubs(:valid?).returns(true)
    put :update, :id => posts(:one)
    assert_redirected_to post_url(assigns(:post))
  end

  def test_destroy
    post = posts(:one)
    delete :destroy, :id => post
    assert_redirected_to posts_url
    assert !Post.exists?(post.id)
  end
end
