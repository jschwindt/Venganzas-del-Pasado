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
      <div class="alert alert-danger">
        <button type="button" class="close" data-dismiss="alert">&times;</button>
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
    object_url = polymorphic_url(object)

    link_to "Facebook",
            "https://www.facebook.com/sharer.php?u=#{url_encode(object_url)}",
            'class'     => "socialite facebook-like",
            'data-href'  => object_url,
            'data-send'  => "false",
            'data-layout' => "button_count",
            'data-width' => "120",
            'data-show-faces' => "false"
  end

  def tweet_button_for(object)
    object_url = polymorphic_url(object)

    link_to "Twitter",
            "https://twitter.com/intent/tweet?via=venganzaspasado&url=#{url_encode(object_url)}",
            'class'     => "socialite twitter-share",
            'data-url'  => object_url,
            'data-via'  => "venganzaspasado",
            'data-lang' => "es",
            'data-hashtags' => "vdp"
  end

  def plusone_button_for(object)
    object_url = polymorphic_url(object)

    link_to "Google+", "https://plus.google.com/share?url=" + url_encode(object_url),
            'class' => 'socialite googleplus-one',
            'data-size' => "tall",
            'data-href' => object_url,
            'data-annotation' => "inline",
            'data-recommendations' => 'false',
            'data-width' => '120'
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, 'el ' + l(time, :format => :long), options.merge(:title => time.getutc.iso8601)) if time
  end

  def show_alerts
    return if flash.empty?

    [:notice, :error, :warning].collect do |key|
      if flash[key].present?
        key_class = "alert-#{key == :notice ? :success : key}"
        content_tag( :div, { :class => "alert #{key_class} fade in" } ) do
          link_to( '&times;'.html_safe, '#', { 'class' => 'close', :data => { :dismiss => "alert"}} ) +
          raw( flash[key] )
        end
      end
    end.join("\n").html_safe
  end

end
