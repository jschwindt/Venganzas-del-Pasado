require 'test_helper'

class Admin::CommentsControllerTest < ActionController::TestCase
    def setup
      sign_in users(:admin)
    end

    def test_index
      get :index, :post_id => posts(:one)
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comments)
      assert_response :success
      assert_template 'index'
    end

    def test_show
      get :show, :post_id => posts(:one), :id => comments(:one)
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comment)
      assert_response :success
      assert_template 'show'
    end

    def test_new
      get :new, :post_id => posts(:one)
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comment)
      assert_response :success
      assert_template 'new'
    end

    def test_create_invalid
  #    Comment.any_instance.stubs(:valid?).returns(false)
      post :create, :post_id => posts(:one), :comment => {}
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comment)
      assert_response :success
      assert_template 'new'
    end

    def test_create_valid
      Comment.any_instance.stubs(:valid?).returns(true)
      post :create, :post_id => posts(:one), :comment => { :content => 'testing' }
      assert_redirected_to post_comments_url(assigns(:post))
    end

    def test_edit
      get :edit, :post_id => posts(:one), :id => comments(:one)
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comment)
      assert_response :success
      assert_template 'edit'
    end

    def test_update_invalid
      Comment.any_instance.stubs(:valid?).returns(false)
      put :update, :post_id => posts(:one), :id => comments(:one)
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:comment)
      assert_response :success
      assert_template 'edit'
    end

    def test_update_valid
      Comment.any_instance.stubs(:valid?).returns(true)
      put :update, :post_id => posts(:one), :id => comments(:one)
      assert_redirected_to post_comments_url(assigns(:post))
    end

    def test_destroy
      comment = Comment.first
      delete :destroy, :post_id => posts(:one), :id => comment
      assert_redirected_to post_comments_url(assigns(:post))
      assert !Comment.exists?(comment.id)
    end
end
