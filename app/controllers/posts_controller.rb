# encoding: utf-8

class PostsController < ApplicationController
  before_filter :authenticate_user!, :only => [:new, :create]
  load_and_authorize_resource
  skip_authorize_resource :only => [:archive, :contributions]

  def index
    @posts = @posts.published.lifo.page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def show
    comments_collection = @post.comments.visible_by(current_user).fifo
    page = params[:page].present? ?
             params[:page] :
             comments_collection.page.per(VenganzasDelPasado::Application.config.comments_per_page).total_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)

    if flash[:created_comment_id]
      @comment = Comment.find(flash[:created_comment_id])
    end
  end

  def archive
    authorize! :index, Post
    @posts = Post.published.lifo.
              created_on(params[:year], params[:month], params[:day]).
              page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def contributions
    authorize! :index, Post
    @posts = Post.contributions.published.
              page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def new
    @post = Post.new
    1.upto(4).each do
      @post.media << Medium.new
    end
  end

  def create
    @post = Post.new_contribution(params[:post], current_user)
    if @post.save
      PostMailer.new_contribution(@post).deliver_now
      redirect_to new_post_url, :notice => "El post '#{@post.title}' se subió con éxito y pronto será revisado y, si corresponde, aprobado. Abajo tenés nuevamente el formulario por si querés cargar más programas."
    else
      @post.media.size.upto(4) do
        @post.media << Medium.new
      end
      render 'new'
    end
  end
end
