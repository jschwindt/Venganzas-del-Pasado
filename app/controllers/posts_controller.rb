# encoding: utf-8

class PostsController < InheritedResources::Base
  
  def show
    show! do | format |
      page = params[:page].present? ? params[:page] : @post.comments.approved.page.num_pages
      @comments = @post.comments.approved.fifo.page page
    end
  end
  
  protected
  def collection
    @posts ||= end_of_association_chain.published.lifo.page(params[:page]).per(5)
  end

end
