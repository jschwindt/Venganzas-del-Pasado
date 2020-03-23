class HomeController < ApplicationController

  def index
    @posts = Post.published.lifo.limit(VenganzasDelPasado::Application.config.home_posts_count)
    @comments = Comment.visible_by(current_user).lifo.limit(VenganzasDelPasado::Application.config.home_comments_count)
  end

end
