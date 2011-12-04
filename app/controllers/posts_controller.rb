# encoding: utf-8

class PostsController < InheritedResources::Base
  load_and_authorize_resource
  
  def show
    show! do | format |
      comments_collection = @post.comments.approved_or_from_user(current_user).fifo
      
      page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
      @comments = comments_collection.page page
    end
  end
  
  protected
  def collection
    @posts ||= end_of_association_chain.published.lifo.page(params[:page]).per(5)
  end

end
