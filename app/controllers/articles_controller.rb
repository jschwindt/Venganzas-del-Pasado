class ArticlesController < ApplicationController
  before_action :find_article_by_slug, only: [:show]
  load_and_authorize_resource

  protected

  def find_article_by_slug
    @article = Article.friendly.find(params[:id])
  end
end
