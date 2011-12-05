module Admin
  class BaseController < InheritedResources::Base
    before_filter :authenticate_user!
    before_filter :verify_admin
    has_scope :page, :default => 1

    private

    def verify_admin
      unless current_user.try(:role) == 'admin'
        redirect_to root_url, :alert => I18n.t('unauthorized.not_admin')
      end
    end
  end
end