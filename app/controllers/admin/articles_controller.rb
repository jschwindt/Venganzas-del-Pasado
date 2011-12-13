module Admin
  class ArticlesController < BaseController

    private

    def verify_admin
      unless current_user.can? :manage, Article
        redirect_to root_url, :alert => I18n.t('unauthorized.not_admin')
      end
    end
  end
end
