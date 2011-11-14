# encoding: utf-8

class CommentsController < InheritedResources::Base
  belongs_to :post

  def index
    @post = Post.find params[:post_id]
    page = params[:page].present? ? params[:page] : @post.comments.approved.page.num_pages
    @comments = @post.comments.approved.fifo.page page
  end

  def create
    create! { collection_url }
  end

  def update
    update! do |success, failure|
      success.html { redirect_to collection_url }
    end
  end
  
end
