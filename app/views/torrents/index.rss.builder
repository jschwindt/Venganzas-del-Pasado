xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title 'Venganzas del Pasado - Torrents de programas recientes'
    xml.description 'Torrents de audios de La Venganza será Terrible'
    xml.link root_url

    for torrent in @torrents
      xml.item do
        xml.title torrent.post.title
        xml.pubDate torrent.post.created_at.rfc822
        xml.link torrent.torrent_url
        xml.guid post_url(torrent.post), :isPermaLink => "true"
        xml.enclosure :url => torrent.torrent_url, :length => 1974, :type => "application/x-bittorrent"
      end
    end
  end
end

