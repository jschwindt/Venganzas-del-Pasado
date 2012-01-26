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

  def markdown_format(text, options = {})
    rndr = Redcarpet::Render::HTML.new(options.reverse_merge(:filter_html => true, :hard_wrap => true))
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

  def fb_like_button_for(object)
    html = <<-HTML
      <iframe src="//www.facebook.com/plugins/like.php?href=#{polymorphic_url(object)}&amp;send=false&amp;layout=button_count&amp;width=120&amp;show_faces=false&amp;action=like&amp;colorscheme=light&amp;font&amp;height=21&amp;appId=128505023893262" scrolling="no" frameborder="0" style="border:none; overflow:hidden; height:21px;" allowTransparency="true"></iframe>
    HTML
    html.html_safe
  end

  def tweet_button_for(object)
    html = <<-HTML
      <a href="https://twitter.com/share" class="twitter-share-button" data-url="#{polymorphic_url(object)}" data-via="venganzaspasado" data-lang="es" data-hashtags="vdp">Tweet</a>
      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0];if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src="//platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>
    HTML
    html.html_safe
  end

  def flash_player?
    cookies[:player] == 'flash'
  end

end
