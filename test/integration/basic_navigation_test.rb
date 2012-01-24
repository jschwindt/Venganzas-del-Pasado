require 'test_helper'

class BasicNavigationTest < ActionDispatch::IntegrationTest

  test "home and post" do
    post = Post.published.lifo.last

    visit "/"
    assert page.has_css?('h3.title', :count => VenganzasDelPasado::Application.config.home_posts_count)
    assert page.has_content?(post.title)

    click_on post.title
    assert_equal current_path, post_path(post)
    assert page.has_css?('h3.title', :count => 1)
    assert page.has_content?(post.title)

    click_on "Programas Recientes"
    assert_equal current_path, posts_path
  end

end