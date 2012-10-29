require 'test_helper'

class RedirectsTest < ActionDispatch::IntegrationTest

  REDIRECT_CASES = {
    '/2011'                                             => '/posts/2011',
    '/2011/12'                                          => '/posts/2011/12',
    '/2011/12'                                          => '/posts/2011/12',
    '/2011/12/09/'                                      => '/posts/2011/12/09',
    '/2011/12/09/la-venganza-sera-terrible-2011-12-09/' => '/posts/la-venganza-sera-terrible-del-09-12-2011',
    '/2011/12/page/5'                                   => '/posts/2011/12?page=5',
    '/acerca-de'                                        => '/articles/acerca-de-este-sitio',
    '/descargas'                                        => '/posts/descargas',
    '/feed'                                             => '/posts.rss',
    '/foro/'                                            => '/',
    '/page/12'                                          => '/',
    '/tags/pepe'                                        => '/',
    '/foro/off-topic-total-1/abc'                       => '/',
    '/sitemap.xml.gz'                                   => '/sitemaps/sitemap_index.xml.gz',
    '/torrent-feed.xml'                                 => '/torrents.rss',
    '/actualizar/'                                      => '/',
    '/actualizar'                                       => '/',
    '/arreglar/'                                        => '/',
    '/arreglar'                                         => '/',
    '/donaciones/'                                      => '/',
    '/donaciones'                                       => '/',
#    '/users/marcela/page/9'                             => '/users/marcela/comments/page/9'
  }

  test "redirects" do
    REDIRECT_CASES.each do |path, result|
      get path
      assert_response 301
      assert_redirected_to result
    end
  end

  test "not found" do
    get '/non-existent-page'
    assert_response :missing
  end

end

