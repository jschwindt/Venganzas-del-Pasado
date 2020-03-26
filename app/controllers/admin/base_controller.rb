module Admin
  class BaseController < InheritedResources::Base
    before_action :authenticate_user!
    before_action :verify_admin
    has_scope :page, default: 1
    layout 'admin'

    def update
      update!(notice: 'Se han guardado los cambios.') do
        edit_resource_url
      end
    end

    def create
      create!(notice: 'Creado correctamente.') do |success, _failure|
        success.html { redirect_to edit_resource_url }
      end
    end

    def dashboard; end

    protected

    def verify_admin
      render '403', status: 403 unless current_user.try(:can_admin?)
    end
  end
end
