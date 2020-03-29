module ApplicationHelper
  def page_title(page_title)
    @page_title = page_title
    full_title = ''
    full_title = "#{page_title} - " if page_title.present?
    full_title += 'Venganzas del Pasado'
    content_for(:title) { strip_tags(full_title) }
  end

  def html_page_title
    @page_title
  end

  def meta_description(text)
    @meta_description = text
  end

  def body_class(klass = nil)
    "#{controller.controller_name}-#{controller.action_name} #{klass}"
  end

  def alert_message_for(object)
    if object.respond_to?(:errors) && object.errors.any?
      messages = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

      html = <<-HTML
      <div class="content notification is-danger">
        <p>
          <strong>Se ha#{object.errors.count > 1 ? 'n' : ''} encontrado #{object.errors.count} error#{object.errors.count > 1 ? 'es' : ''}:</strong>
        </p>
        <ul>#{messages}</ul>
      </div>
      HTML

      html.html_safe
    end
  end

  def active_if_current(action)
    current_page?(action) ? 'is-active' : ''
  end

  def markdown_format(text, options = {})
    rndr = Redcarpet::Render::HTML.new(options.reverse_merge(filter_html: true, hard_wrap: true))
    markdown = Redcarpet::Markdown.new(
      rndr,
      autolink: true,
      strikethrough: true,
      no_intra_emphasis: true,
      space_after_headers: true
    )
    markdown.render(text).html_safe
  end

  def timeago(time, options = {})
    return unless time

    options[:class] ||= 'timeago'
    content_tag(:abbr, 'el ' + l(time, format: :long),
                options.merge(title: time.getutc.iso8601, datetime: time.getutc.iso8601))
  end
end
