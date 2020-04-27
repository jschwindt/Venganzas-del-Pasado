require 'test_helper'

class AdminArticlesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'redirect to login if logged out' do
    get admin_articles_url
    assert_redirected_to new_user_session_url
  end

  test 'denied access to plain users, editors and moderators' do
    sign_in users(:one)
    get admin_articles_url
    assert_response 403

    sign_in users(:editor)
    get admin_articles_url
    assert_response 403

    sign_in users(:moderator)
    get admin_articles_url
    assert_response 403
  end

  test 'show articles to admins' do
    sign_in users(:admin)
    get admin_articles_url
    assert_response :success
  end

  test 'should show new form' do
    sign_in users(:admin)
    get new_admin_article_url
    assert_response :success
  end

  test 'should create article' do
    sign_in users(:admin)
    post admin_articles_url, params: {
      article: { title: 'A Draft', content: 'Some content', created_at: DateTime.now }
    }
    assert_equal flash[:notice], 'Creado correctamente.'
    assert_response 302
  end

  test 'should show edit form' do
    sign_in users(:admin)
    get edit_admin_article_url(articles(:one))
    assert_response :success
  end

  test 'should update article' do
    sign_in users(:admin)
    article = articles(:one)
    patch admin_article_url(article), params: {
      article: { title: 'Changed title', content: 'Some content', created_at: DateTime.now }
    }
    assert_equal flash[:notice], 'Se han guardado los cambios.'
    assert_redirected_to edit_admin_article_url(article)
  end
end
