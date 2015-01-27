class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?

  protect_from_forgery
  helper :smilies

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render '404', :status => 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    render '403', :status => 403, :alert => exception.message
  end

  def after_sign_in_path_for(resource_or_scope)
    request.env['omniauth.origin'] || stored_location_for(resource_or_scope) || root_path
  end

  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      "lean"
    else
      "application"
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :alias
  end

end
