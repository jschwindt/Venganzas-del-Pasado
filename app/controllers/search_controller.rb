class SearchController < ApplicationController
  def index
    return texts if params[:what] == 'texts'

    @what = params[:what] == 'comments' ? 'comments' : 'posts'

    @posts_result = Post.search(params[:q],
                  page: params[:page] || 1,
                  hits_per_page: VenganzasDelPasado::Application.config.posts_search_per_page)

    @comments_result = Comment.search(params[:q],
                  page: params[:page] || 1,
                  hits_per_page: VenganzasDelPasado::Application.config.comments_search_per_page)

    @results = @what == 'comments' ? @comments_result : @posts_result
  end

  def texts
    args = { created_at: {} }
    filters = []
    if params[:date_from].present? && params[:date_from][:year].present? && params[:date_from][:month].present?
      filters << "timestamp >= #{Time.new(params[:date_from][:year], params[:date_from][:month], 1).to_i}"
      args[:created_at][:gte] = '%4d-%02d' % [params[:date_from][:year], params[:date_from][:month]]
    end
    if params[:date_to].present? && params[:date_to][:year].present? && params[:date_to][:month].present?
      args[:created_at][:lte] = '%4d-%02d' % [params[:date_to][:year], params[:date_to][:month]]
      filters << "timestamp <= #{Time.new(params[:date_to][:year], params[:date_to][:month], 1).end_of_month.to_i}"
    end

    @results = Text.search(params[:q],
      page: params[:page] || 1,
      hits_per_page: VenganzasDelPasado::Application.config.comments_search_per_page,
      highlight_pre_tag: "***",
      highlight_post_tag: "***",
      filter: filters.join(' AND '),
    )

    render :texts
  end
end
