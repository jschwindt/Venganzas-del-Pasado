class HomeController < ApplicationController

  def index
    @posts = Post.published.lifo.limit(3)
  end

end
