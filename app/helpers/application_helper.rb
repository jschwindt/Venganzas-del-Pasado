module ApplicationHelper

  def title(page_title, show_title = true)
    content_for(:title) { h(page_title.to_s) }
    @show_title = show_title
  end

  def show_title?
    @show_title
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def markdown_format(text)
    rndr = Redcarpet::Render::HTML.new(:filter_html => true, :hard_wrap => true)
    markdown = Redcarpet::Markdown.new(
        rndr,
        :autolink            => true,
        :no_intra_emphasis   => true,
        :space_after_headers => true)
    markdown.render(text).html_safe
  end

  def gravatar_url_for(object)
    if object.respond_to? :gravatar_hash
      "http://www.gravatar.com/avatar/#{object.gravatar_hash}?s=60&d=mm"
    end
  end

end
