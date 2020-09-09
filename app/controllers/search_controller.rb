class SearchController < ApplicationController
  def index
    return texts if params[:what] == 'texts'

    @what = params[:what] == 'comments' ? 'comments' : 'posts'

    post_q = Post.search(params[:q],
                  execute: false, load: @what == 'posts',
                  page: params[:page],
                  per_page: VenganzasDelPasado::Application.config.posts_search_per_page)

    comment_q = Comment.search(params[:q],
                  execute: false, load: @what == 'comments',
                  page: params[:page],
                  per_page: VenganzasDelPasado::Application.config.comments_search_per_page)

    @posts_result, @comments_result = Searchkick.multi_search([post_q, comment_q])

    @results = @what == 'comments' ? @comments_result : @posts_result
  end

  def texts
    args = { created_at: {} }
    if params[:date_from].present? && params[:date_from][:year].present? && params[:date_from][:month].present?
      args[:created_at][:gte] = '%4d-%02d' % [params[:date_from][:year], params[:date_from][:month]]
    end
    if params[:date_to].present? && params[:date_to][:year].present? && params[:date_to][:month].present?
      args[:created_at][:lte] = '%4d-%02d' % [params[:date_to][:year], params[:date_to][:month]]
    end

    @results = Text.search(params[:q], where: args, highlight: {tag: '***'},
      page: params[:page],
      per_page: VenganzasDelPasado::Application.config.comments_search_per_page)
    render :texts
  end
end
