class HomeController < ApplicationController

  def index
    @posts = Post.published.lifo.limit(VenganzasDelPasado::Application.config.home_posts_count)
    @comments = Comment.visible_by(current_user).lifo.limit(VenganzasDelPasado::Application.config.home_comments_count)
  end

  def switch_player
    cookies.permanent[:player] = cookies[:player] == 'flash' ? 'html5' : 'flash'
    redirect_to root_path
  end

end
