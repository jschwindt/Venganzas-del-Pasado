module ApplicationHelper

  def page_title( page_title )
    @page_title = page_title
    full_title = ''
    full_title = "#{page_title} - " if page_title.present?
    full_title += "Venganzas del Pasado"
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
    if object.respond_to? :errors and object.errors.any?
      messages = object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

      html = <<-HTML
      <div class="alert-message block-message error">
        #{ link_to "x", "#", :class => 'close' }
        <p>
          <strong>Se ha#{object.errors.count > 1 ? 'n' : ''} encontrado #{object.errors.count} error#{object.errors.count > 1 ? 'es' : ''}</strong>
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

  def markdown_format(text, options = {})
    rndr = Redcarpet::Render::HTML.new(options.reverse_merge(:filter_html => true, :hard_wrap => true))
    markdown = Redcarpet::Markdown.new(
        rndr,
        :autolink            => true,
        :no_intra_emphasis   => true,
        :space_after_headers => true)
    markdown.render(text).html_safe
  end

  def fb_like_button_for(object)
    html = <<-HTML
      <iframe src="//www.facebook.com/plugins/like.php?href=#{polymorphic_url(object)}&amp;send=false&amp;layout=button_count&amp;width=120&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21&amp;appId=128505023893262" scrolling="no" frameborder="0" style="border:none; overflow:hidden; height:21px;" allowTransparency="true"></iframe>
    HTML
    html.html_safe
  end

  def tweet_button_for(object)
    link_to "Compartir VdP en Twitter", "https://twitter.com/share",
            'class'     => "twitter-share-button",
            'data-url'  => polymorphic_url(object),
            'data-via'  => "venganzaspasado",
            'data-lang' => "es",
            'data-hashtags' => "vdp"
  end

  def flash_player?
    cookies[:player] == 'flash'
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, 'el' + l(time, :format => :long), options.merge(:title => time.getutc.iso8601)) if time
  end

end
