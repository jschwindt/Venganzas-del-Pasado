class PostsController < ApplicationController
  load_and_authorize_resource
  before_filter :find_post, :only => [:show, :edit, :update]

  def index
    @posts = Post.published.lifo.page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def show
    comments_collection = @post.comments.approved_or_from_user(current_user).fifo
    page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def edit
  end

  def update
    if @post.update_attributes(params[:post])
      flash[:notice] = "Successfully updated post."
      redirect_to @post
    else
      render 'edit'
    end
  end

  protected

  def find_post
    @post = Post.find(params[:id])
  end

end
