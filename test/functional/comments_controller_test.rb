require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:one)
  end

  test "create valid" do
    post :create, :post_id => posts(:one), :comment => { :content => 'testing' }
    assert assigns(:post)
    assert assigns(:comment)
    assert_redirected_to "#{post_path(assigns(:post))}#comment-#{assigns(:comment).id}"
  end

  test "show comment" do
    comment = comments(:approved)
    get :show, :post_id => comment.post, :id => comment
    assert assigns(:post)
    assert assigns(:comment)
    assert_template 'show'
    assert_response :success
  end

  test "flag comment" do
    comment = comments(:one)
    xhr :post, :flag, :id => comment
    assert assigns(:comment)
    assert_template 'flag'
    assert_response :success
  end

  test "like comment" do
    comment = comments(:one)
    xhr :post, :like, :id => comment
    assert assigns(:comment)
    assert_template 'like'
    assert_response :success
  end

  test "dislike comment" do
    comment = comments(:one)
    xhr :post, :dislike, :id => comment
    assert assigns(:comment)
    assert_template 'dislike'
    assert_response :success
  end

end
