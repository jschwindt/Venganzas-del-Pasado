require 'test_helper'

class AudiosControllerTest < ActionController::TestCase

  test "should get audio popup" do
    get :show, :post_id => posts(:one), :id => audios(:one)
    assert_response :success
    assert_template 'show'
    assert_not_nil assigns(:post)
    assert_not_nil assigns(:audio)
  end

end
