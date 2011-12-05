# encoding: utf-8

class CommentsController < InheritedResources::Base
  belongs_to :post
  load_and_authorize_resource :post
  load_and_authorize_resource :comment, :through => :post

  def index
    comments_collection = @post.comments.approved_or_from_user(current_user).fifo

    page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
    @comments = comments_collection.page(page).per(VenganzasDelPasado::Application.config.comments_per_page)
  end

  def create
    @comment = @post.comments.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.author = current_user.alias
    @comment.author_email = current_user.email
    @comment.author_ip = request.remote_ip

    if can? :approve, @comment
      @comment.status =  'approved'
    else
      @comment.status = 'pending'
    end

    @comment.gravatar_hash = current_user.gravatar_hash

    create! { "#{parent_url}#comment#{@comment.id}" }
  end

  def update
    update! do |success, failure|
      success.html { redirect_to resource_url }
    end
  end

end
