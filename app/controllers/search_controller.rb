class SearchController < ApplicationController
  def index
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
end
