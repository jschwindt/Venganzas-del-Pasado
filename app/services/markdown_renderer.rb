class MarkdownRenderer
  DEFAULT_RENDER_OPTIONS = {
    filter_html: true,
    hard_wrap: true
  }.freeze

  EXTENSIONS = {
    autolink: true,
    no_intra_emphasis: true,
    space_after_headers: true,
    strikethrough: true
  }.freeze

  class << self
    def render(text, render_options: {}, extensions: {})
      renderer = Redcarpet::Render::HTML.new(DEFAULT_RENDER_OPTIONS.merge(render_options))
      markdown = Redcarpet::Markdown.new(renderer, EXTENSIONS.merge(extensions))

      markdown.render(text.to_s)
    end
  end
end
