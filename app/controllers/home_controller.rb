class HomeController < ApplicationController
  def index
    @posts = Post.published.lifo.find(:all, :limit => 3)
    @activities = [
      {},
      {},
      {},
      {},
      {}
    ]
  end

end
