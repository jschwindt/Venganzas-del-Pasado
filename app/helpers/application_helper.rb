module ApplicationHelper

  def page_title( page_title )
    @page_title = page_title
    content_for(:title) { strip_tags(@page_title) }
  end

  def html_page_title
    @page_title
  end

  def body_class
    "#{controller.controller_name}-#{controller.action_name}"
  end

  def alert_message_for(object)
    if object.respond_to? :errors and object.errors.any?
      messages = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

      html = <<-HTML
      <div class="alert-message block-message error">
        #{ link_to "x", "#", :class => 'close' }
        <p>
          <strong>Se ha encontrado #{pluralize(object.errors.count, "error")}</strong>
        </p>
        <ul>#{ messages }</ul>
      </div>
      HTML

      html.html_safe
    end
  end

  def active_if_current(action)
    current_page?(action) ? 'active' : 'inactive'
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

  def gravatar_url_for(object, options = {})
    if object.respond_to? :gravatar_hash
      default_options = { :s => 60, :d => 'mm' }
      "http://www.gravatar.com/avatar/#{object.gravatar_hash}?#{default_options.merge!(options).to_query}"
    end
  end

end
