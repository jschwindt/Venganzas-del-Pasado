module Admin
  class ArticlesController < BaseController

    private

    def verify_admin
      unless current_user.can? :manage, Article
        render '403', :status => 403
      end
    end
  end
end
