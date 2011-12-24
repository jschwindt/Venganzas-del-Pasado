class ApplicationController < ActionController::Base
  protect_from_forgery
  helper :smilies

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render '404', :status => 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    render '403', :status => 403, :alert => exception.message
  end
end
