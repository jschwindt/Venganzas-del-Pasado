class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def after_sign_in_path_for(resource_or_scope)
    request.env['omniauth.origin'] || stored_location_for(resource_or_scope) || root_path
  end

  layout :layout_by_resource

  protected

  def layout_by_resource
    if devise_controller?
      'lean'
    else
      'application'
    end
  end

  def not_found
    respond_to do |format|
      format.html { render '404.html', status: 404 }
      format.json { render json: { error: 'not_found' }, status: 404 }
    end
  end
end
