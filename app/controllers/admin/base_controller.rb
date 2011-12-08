# encoding: utf-8

module Admin
  class BaseController < InheritedResources::Base
    before_filter :authenticate_user!
    before_filter :verify_admin
    has_scope :page, :default => 1

    def update
      update!(:notice => "Se han guardado los cambios.") do
        edit_resource_url
      end
    end

    def create
      create! do |success, failure|
        success.html { redirect_to edit_resource_url }
      end
    end

    def dashboard

    end

    private

    def verify_admin
      unless current_user.try(:role) == 'admin'
        redirect_to root_url, :alert => I18n.t('unauthorized.not_admin')
      end
    end
  end
end
