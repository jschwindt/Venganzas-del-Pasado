class CommentsController < ApplicationController
  before_filter :find_post
  
  def index
    page = params[:page].present? ? params[:page] : @post.comments.page.num_pages
    @comments = @post.comments.order("created_at ASC").page page
  end

  def show
    @comment = @post.comments.find(params[:id])
  end

  def new
    @comment = @post.comments.new
  end

  def create
    @comment = @post.comments.new(params[:comment])
    if @comment.save
      redirect_to post_comments_path(@post), :notice => "Successfully created comment."
    else
      render :action => 'new'
    end
  end

  def edit
    @comment = @post.comments.find(params[:id])
  end

  def update
    @comment = @post.comments.find(params[:id])
    if @comment.update_attributes(params[:comment])
      redirect_to post_comments_path(@post), :notice  => "Successfully updated comment."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])
    @comment.destroy
    redirect_to post_comments_path(@post), :notice => "Successfully destroyed comment."
  end
  
private
  def find_post
    @post = Post.find params[:post_id]
  end
end
