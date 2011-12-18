# encoding: utf-8

module Admin
  class BaseController < InheritedResources::Base
    before_filter :authenticate_user!
    before_filter :verify_admin
    has_scope :page, :default => 1
    with_role :admin

    def update
      update!(:notice => "Se han guardado los cambios.") do
        edit_resource_url
      end
    end

    def create
      create!(:notice => "Creado correctamente.") do |success, failure|
        success.html { redirect_to edit_resource_url }
      end
    end

    def dashboard

    end

    private

    def verify_admin
      unless current_user.try(:can_admin?)
        render '403', :status => 403
      end
    end
  end
end
