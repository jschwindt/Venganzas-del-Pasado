# encoding: utf-8

class PostsController < InheritedResources::Base

  protected
  def collection
    @posts ||= end_of_association_chain.published.lifo.page(params[:page])
  end

end
