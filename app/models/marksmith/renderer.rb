module Marksmith
  class Renderer
    PREVIEW_EXTENSIONS = {
      fenced_code_blocks: true,
      highlight: true,
      lax_spacing: true,
      quote: true,
      tables: true,
      underline: false,
      with_toc_data: true
    }.freeze

    def initialize(body:)
      @body = body
    end

    def render
      MarkdownRenderer.render(
        @body,
        render_options: { filter_html: false },
        extensions: PREVIEW_EXTENSIONS
      )
    end
  end
end
