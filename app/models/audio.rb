class Audio < ActiveRecord::Base
  belongs_to :post

  validates :url, :presence => true
  
  def torrent_url
    # Pasa de http://venganzasdelpasado.com.ar/2011/lavenganza_2011-11-22.mp3
    #       a    http://s3.schwindt.org/dolina/2011/lavenganza_2011-11-22.mp3?torrent
    url.sub %r[^http://venganzasdelpasado.com.ar(/\d{4}/lavenganza_\d{4}-\d{2}-\d{2}\.mp3)$],
            'http://s3.schwindt.org/dolina\1?torrent'
  end
end
