module Admin
  class ArticlesController < BaseController
    before_action :load_collection, only: :index
    before_action :load_resource, except: %i[index new create]
    authorize_resource

    protected

    def verify_admin
      render '403', status: 403 unless current_user.can? :manage, Article
    end

    def load_collection
      @articless = apply_scopes Article
    end

    def load_resource
      @article = Article.friendly.find(params[:id])
    end

    def article_params
      params.require(:article).permit(%i[title content created_at])
    end
  end
end
