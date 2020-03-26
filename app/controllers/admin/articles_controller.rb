module Admin
  class ArticlesController < BaseController
    load_and_authorize_resource

    protected

    def verify_admin
      render '403', status: 403 unless current_user.can? :manage, Article
    end
  end
end
