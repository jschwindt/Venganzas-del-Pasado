class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :smilies
  before_filter :get_last_post

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render '404', :status => 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    render '403', :status => 403, :alert => exception.message
  end

  def after_sign_in_path_for(resource_or_scope)
    request.env['omniauth.origin'] || stored_location_for(resource_or_scope) || root_path
  end
  
  private
  
  def get_last_post
    @last_post = Post.published.lifo.first
  end
  
end
