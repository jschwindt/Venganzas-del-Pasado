xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0", 'xmlns:atom' => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Programas Recientes - Venganzas del Pasado"
    xml.description "Archivos MP3 del programa de radio La Venganza Será Terrible de Alejandro Dolina"
    xml.link posts_url(:rss)
    xml.atom :link, :href => posts_url(:rss), :rel => "self", :type => "application/rss+xml"

    for post in @posts
      xml.item do
        xml.title post.title
        xml.description markdown_format post.content
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post_url post
        xml.guid post_url post
        post.audios.each do |audio|
          xml.enclosure :url => audio.url, :length => audio.bytes, :type => "audio/mpeg"
        end
      end
    end
  end
end
