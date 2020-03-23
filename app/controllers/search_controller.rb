class SearchController < ApplicationController

  def index
    @what = params[:what] == 'comments' ? 'comments' : 'posts'
    search_opts = { order: :created_at, sort_mode: :desc, match_mode: :boolean }
    q = Riddle::Query.escape(params[:q] || '')
    @facets = ThinkingSphinx.facets(q, search_opts)
    @facets[:class].reverse_merge!('Post' => 0, 'Comment' => 0 )

    @results = @what.classify.constantize.search(q, search_opts).
                  page(params[:page]).
                  per(VenganzasDelPasado::Application.config.send "#{@what}_search_per_page")
  end

end
