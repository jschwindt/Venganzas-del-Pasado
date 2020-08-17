class PostsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]
  before_action :find_page_by_slug, only: [:show]
  load_and_authorize_resource
  skip_authorize_resource only: %i[archive contributions]

  def index
    posts_per_page = VenganzasDelPasado::Application.config.posts_per_page
    respond_to do |format|
      format.html
      format.rss { posts_per_page = VenganzasDelPasado::Application.config.posts_per_page_rss }
    end
    @posts = @posts.published.lifo.page(params[:page]).per(posts_per_page)
  end

  def show
    comments_collection = @post.comments.visible_by(current_user).fifo
    page = params[:page].present? ?
             params[:page] :
             comments_collection.page.per(VenganzasDelPasado::Application.config.comments_per_page).total_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def archive
    authorize! :index, Post
    if request.xhr?
      @year = params[:year].to_i
      @monthly_posts = Post.post_count_by_month(params[:year])
      return
    end

    @posts = Post.published.lifo
                 .created_on(params[:year], params[:month], params[:day])
                 .page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def contributions
    authorize! :index, Post
    @posts = Post.contributions.published
                 .page(params[:page]).per(VenganzasDelPasado::Application.config.posts_per_page)
  end

  def new
    @post = Post.new
    1.upto(4).each do
      @post.media << Medium.new
    end
  end

  def create
    @post = Post.new_contribution(post_params, current_user)
    if @post.save
      PostMailer.with(post: @post).new_contribution.deliver_now
      redirect_to new_post_url, notice: "El post '#{@post.title}' se subió con éxito y pronto será revisado y, si corresponde, aprobado. Abajo tenés nuevamente el formulario por si querés cargar más programas."
    else
      @post.media.size.upto(4) do
        @post.media << Medium.new
      end
      render 'new'
    end
  end

  protected

  def find_page_by_slug
    @post = Post.friendly.find(params[:id])
  end

  def post_params
    params.require(:post).permit([:title, :content, :created_at, media_attributes: [:asset]])
  end
end
