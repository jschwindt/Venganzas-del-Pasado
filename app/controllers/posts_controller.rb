class PostsController < ApplicationController
  load_and_authorize_resource

  def index
    @posts = @posts.published.lifo.page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def show
    comments_collection = @post.comments.approved_or_from_user(current_user).fifo
    page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

end
