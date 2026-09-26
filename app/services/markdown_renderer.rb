class MarkdownRenderer
  DEFAULT_RENDER_OPTIONS = {
    hard_wrap: true
  }.freeze

  SAFE_RENDER_OPTIONS = {
    safe_links_only: true
  }.freeze

  ALLOWED_TAGS = %w[
    a blockquote br code del em h1 h2 h3 h4 h5 h6 hr img li ol p pre
    strong table tbody td th thead tr ul
  ].freeze

  ALLOWED_ATTRIBUTES = %w[
    alt class href src title
  ].freeze

  EXTENSIONS = {
    autolink: true,
    no_intra_emphasis: true,
    space_after_headers: true,
    strikethrough: true
  }.freeze

  class << self
    def render(text, render_options: {}, extensions: {})
      renderer = Redcarpet::Render::HTML.new(
        DEFAULT_RENDER_OPTIONS.merge(render_options).merge(SAFE_RENDER_OPTIONS)
      )
      markdown = Redcarpet::Markdown.new(renderer, EXTENSIONS.merge(extensions))

      sanitizer.sanitize(
        markdown.render(text.to_s),
        tags: ALLOWED_TAGS,
        attributes: ALLOWED_ATTRIBUTES
      )
    end

    private

    def sanitizer
      @sanitizer ||= Rails::HTML5::SafeListSanitizer.new
    end
  end
end
