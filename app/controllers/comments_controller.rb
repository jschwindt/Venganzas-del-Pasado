# encoding: utf-8

class CommentsController < InheritedResources::Base
  belongs_to :post

  def index
    @post = Post.find params[:post_id]
    
    if(current_user)
      comments_collection = @post.comments.approved_or_from_user(current_user).fifo
    else
      comments_collection = @post.comments.approved.fifo
    end
    
    page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
    
    @comments = comments_collection.page page

  end

  def create
    @comment = Comment.new(params[:comment])
    @comment.user_id = current_user.id
    @comment.author_ip = request.remote_ip
    
    if can? :autoapprove, @comment 
      @comment.status =  'approved'
    else
      @comment.status = 'pending'
    end
    
    create! { "#{collection_url}#comment#{@comment.id}" }
  end

  def update
    update! do |success, failure|
      success.html { redirect_to collection_url }
    end
  end

end
