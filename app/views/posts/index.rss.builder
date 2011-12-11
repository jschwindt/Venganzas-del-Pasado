xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Publicaciones Recientes"
    xml.description "Archivos MP3 del programa de radio La Venganza Será Terrible de Alejandro Dolina"
    xml.link posts_path(:rss, :only_path => false)

    for post in @posts
      xml.item do
        xml.title post.title
        xml.description markdown_format post.content
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link post_path post, :only_path => false
        xml.guid post_path post, :only_path => false
      end
    end
  end
end
