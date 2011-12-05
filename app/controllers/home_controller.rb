class HomeController < ApplicationController

  def index
    @posts = Post.published.lifo.limit(VenganzasDelPasado::Application.config.home_posts_count)
  end

end
