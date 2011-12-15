require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:one)
  end

  def test_create_valid
    post :create, :post_id => posts(:one), :comment => { :content => 'testing' }
    assert assigns(:post)
    assert assigns(:comment)
#    assert_redirected_to "#{post_path(@post)}#comment#{@comment.id}"
  end

end
