class TorrentsController < ApplicationController
  
  def index
    @torrents = Audio.includes(:post).
                    order('posts.created_at DESC').
                    page(params[:page]).
                    per(VenganzasDelPasado::Application.config.torrents_per_page)
  end

end
