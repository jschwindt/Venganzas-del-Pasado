require 'test_helper'

class CommentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should show comment' do
    get post_comment_url(comments(:one).post, comments(:one))
    assert_response :success
  end

  test 'should not allow to create comment if logged out' do
    assert_raises CanCan::AccessDenied do
      post post_comments_url(posts(:published)), params: { comment: { content: 'Hola' } }
    end
  end

  test 'should not allow to flag comment if logged out' do
    assert_raises CanCan::AccessDenied do
      post flag_comment_url comments(:one)
    end
  end

  test 'should create comment if logged in' do
    sign_in users(:one)
    post = posts(:published)
    assert_difference 'Comment.count' do
      post post_comments_url(post), params: { comment: { content: 'Hola' } }
      assert_response 302
    end
  end

  test 'should flag comment if logged in' do
    sign_in users(:one)
    post flag_comment_url(comments(:one)), xhr: true
    assert_equal ActionMailer::Base.deliveries.first.subject, 'Comentario denunciado'
    assert_response :success
  end
end
