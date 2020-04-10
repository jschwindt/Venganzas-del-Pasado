xml.instruct! :xml, version: '1.0'
xml.rss version: '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do
  xml.channel do
    xml.title 'Venganzas del Pasado - Programas Recientes'
    xml.description "Archivos MP3 del programa de radio 'La Venganza Será Terrible' de Alejandro Dolina"
    xml.link root_url
    if @posts.first_page?
      xml.atom :link, href: posts_url(:rss), rel: 'self', type: 'application/rss+xml'
    else
      xml.atom :link, href: posts_url(:rss, page: @posts.current_page), rel: 'self', type: 'application/rss+xml'
    end

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description markdown_format post.content
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post_url post
        xml.guid post_url post
        post.audios.each do |audio|
          xml.enclosure url: audio.url, length: audio.bytes, type: 'audio/mpeg'
        end
      end
    end
    unless @posts.first_page?
      xml.link href: posts_url(:rss, page: @posts.current_page - 1), rel: 'previous', type: 'application/rss+xml'
    end
    unless @posts.last_page?
      xml.link href: posts_url(:rss, page: @posts.current_page + 1), rel: 'next', type: 'application/rss+xml'
    end
  end
end
