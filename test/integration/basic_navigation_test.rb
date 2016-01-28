# encoding: utf-8

require 'test_helper'

class BasicNavigationTest < ActionDispatch::IntegrationTest

  test 'home and post' do
    post = Post.published.lifo.last

    visit root_path
    assert page.has_css?('h3.title', :count => VenganzasDelPasado::Application.config.home_posts_count)
    assert page.has_content?(post.title)

    first('h3 a').click
    assert_equal current_path, post_path(post)
    assert page.has_css?('h1.title', :count => 1)
    assert page.has_content?(post.title)

    first(:link, 'Programas Recientes').click
    assert_equal current_path, posts_path
  end

  test 'user login' do
    create_user('user@example.com', 'secret', 'username')
    visit root_path
    click_on 'Iniciar Sesión'

    first('#user_email').set @user.email
    first('#user_password').set 'secret'
    first(:button, 'Ingresar').click
    assert_equal current_path, root_path
    assert page.has_content?('username')
  end

  def create_user(email, password, user_alias, role='')
    @user = User.new(:email => email,
                    :alias  => user_alias,
                    :password => password,
                    :password_confirmation => password)
    @user.skip_confirmation!
    @user.role = role
    @user.save!
  end
end
