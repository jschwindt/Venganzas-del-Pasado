xml.instruct! :xml, :version => '1.0' 
xml.rss :version => '2.0' do
  xml.channel do
    xml.title 'Venganzas del Pasado'
    xml.description 'Torrents de audios de La Venganza será Terrible'
    xml.link 'http://venganzasdelpasado.com.ar/'
    
    for torrent in @torrents
      xml.item do
        xml.title torrent.post.title
        xml.pubDate torrent.post.created_at.rfc822
        xml.link torrent.torrent_url
      end
    end
  end
end

