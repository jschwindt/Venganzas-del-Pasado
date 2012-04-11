require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  test "should get index" do
    get :index
    assert_response :success
    assert_template 'index'
    assert_not_nil assigns(:posts)
  end

  test "should get show" do
    get :show, :id => posts(:one)
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:post)
  end

  test "should get archive index" do
    get :archive
    assert_response :success
    assert_template 'archive'
    assert_not_nil assigns(:posts)
  end

  test "should get contributions index" do
    get :contributions
    assert_response :success
    assert_template 'contributions'
    assert_not_nil assigns(:posts)
  end

  test "should get new contribution form" do
    sign_in users(:one)
    get :new
    assert_response :success
    assert_template 'new'
    assert_not_nil assigns(:post)
  end

  test "should accept valid contribution" do
    sign_in users(:one)
    Post.any_instance.expects(:save).returns(true)
    post :create, :post => { :title => 'Contribution', :created_at => Date.civil }
    assert_redirected_to new_post_url
    assert_not_nil assigns(:post)
  end

  test "should refuse invalid contribution" do
    sign_in users(:one)
    Post.any_instance.expects(:save).returns(false)
    post :create, :post => { :title => 'Contribution', :created_at => Date.civil }
    assert_not_nil assigns(:post)
    assert_response :success
    assert_template 'new'
  end

end
