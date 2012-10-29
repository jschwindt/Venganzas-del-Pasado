class RedirectsController < ApplicationController

  def index
    case params[:path]

    when %r{^(\d{4})/(\d{2})/(\d{2})/la-venganza-sera-terrible}
      # /2011/12/09/la-venganza-sera-terrible-2011-12-09/ => /posts/la-venganza-sera-terrible-del-28-11-2011
      redirect_to "/posts/la-venganza-sera-terrible-del-#{$3}-#{$2}-#{$1}", :status => :moved_permanently

    when %r{^(\d{4})/(\d{2})/(\d{2})}
      # /2011/12/09/ => /posts/2011/12/09
      redirect_to "/posts/#{$1}/#{$2}/#{$3}",                               :status => :moved_permanently

    when %r{^(\d{4})/(\d{2})/page/(\d+)}
      # /2011/12/page/5 => /posts/2011/12?page=5
      redirect_to "/posts/#{$1}/#{$2}?page=#{$3}",                          :status => :moved_permanently

    when %r{^(\d{4})/(\d{2})}
      # /2011/12 => /posts/2011/12
      redirect_to "/posts/#{$1}/#{$2}",                                     :status => :moved_permanently

    when %r{^(\d{4})}
      # /2011 => /posts/2011
      redirect_to "/posts/#{$1}",                                           :status => :moved_permanently

    when 'feed'
      redirect_to "/posts.rss",                                             :status => :moved_permanently

    when 'acerca-de'
      redirect_to "/articles/acerca-de-este-sitio",                         :status => :moved_permanently

    when 'descargas'
      redirect_to "/posts/descargas",                                       :status => :moved_permanently

    when 'torrent-feed.xml'
      redirect_to "/torrents.rss",                                          :status => :moved_permanently

    when 'sitemap.xml.gz'
      redirect_to "/sitemaps/sitemap_index.xml.gz",                         :status => :moved_permanently

    when  %r{^(page|foro|tag|actualizar|arreglar|donaciones)}
      redirect_to "/",                                                      :status => :moved_permanently

    when %r{^users/([^/]+)/page/(\d+)}
      # /users/marcela/page/1 => /users/marcela/comments/page/1
      redirect_to "/users/#{$1}/comments/page/#{$2}",                       :status => :moved_permanently

    else
      render '404', :status => 404
    end
  end

end
