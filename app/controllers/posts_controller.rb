# encoding: utf-8

class PostsController < InheritedResources::Base
  
  def show
    show! do | format |
      if(current_user)
        comments_collection = @post.comments.approved_or_from_user(current_user).fifo
      else
        comments_collection = @post.comments.approved.fifo
      end
    
      page = params[:page].present? ? params[:page] : comments_collection.page.num_pages
      @comments = comments_collection.page page
    end
  end
  
  protected
  def collection
    @posts ||= end_of_association_chain.published.lifo.page(params[:page]).per(5)
  end

end
