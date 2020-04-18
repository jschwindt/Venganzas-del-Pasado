# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://venganzasdelpasado.com.ar"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host

  add posts_path, :changefreq => 'daily'

  Post.published.lifo.find_each do |post|
    add post_path(post), :lastmod => post.updated_at, :changefreq => 'daily', :priority => 0.8
  end

  add torrents_path, :changefreq => 'daily'

  Article.find_each do |article|
    add article_path(article), :lastmod => article.updated_at
  end

  User.find_each do |user|
    add user_path(user), :lastmod => user.updated_at
  end



end
