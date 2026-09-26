require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "alert_message_for" do
    post = Post.new(status: "published", created_at: Date.today)
    post.valid?
    expected = <<-HTML
      <div class="content notification is-danger">
        <p>
          <strong>Se ha encontrado 1 error:</strong>
        </p>
        <ul><li>Título no puede estar en blanco</li></ul>
      </div>
    HTML

    assert_dom_equal expected, alert_message_for(post)
  end

  test "markdown_format renders underscore emphasis as italic" do
    expected = "<p>Texto <em>en cursiva</em>.</p>"

    assert_dom_equal expected, markdown_format("Texto _en cursiva_.")
  end

  test "markdown_format does not render emphasis inside words" do
    expected = "<p>Texto_en_cursiva.</p>"

    assert_dom_equal expected, markdown_format("Texto_en_cursiva.")
  end

  test "markdown_format preserves supported post and comment formatting" do
    markdown = <<~MARKDOWN
      # Título

      **negrita**, _cursiva_ y [enlace](https://example.com).

      - uno
      - dos

      > una cita

      ![imagen](https://example.com/image.png "Descripción")

      <strong>HTML seguro existente</strong>
    MARKDOWN

    rendered = markdown_format(markdown)
    fragment = Nokogiri::HTML5.fragment(rendered)

    assert_select fragment, "h1", text: "Título"
    assert_select fragment, "strong", text: "negrita"
    assert_select fragment, "em", text: "cursiva"
    assert_select fragment, "a[href='https://example.com']", text: "enlace"
    assert_select fragment, "ul li", count: 2
    assert_select fragment, "blockquote", text: /una cita/
    assert_select fragment, "img[src='https://example.com/image.png'][alt='imagen'][title='Descripción']", count: 1
    assert_select fragment, "strong", text: "HTML seguro existente"
  end

  test "markdown_format removes executable HTML and unsafe URLs" do
    markdown = <<~MARKDOWN
      <script>alert('script')</script>
      <div onclick="alert('event')"><img src="x" onerror="alert('image')"></div>
      <iframe src="https://example.com"></iframe>
      [enlace peligroso](javascript:alert('link'))
      ![imagen peligrosa](data:image/svg+xml;base64,PHN2Zz48L3N2Zz4=)
    MARKDOWN

    rendered = markdown_format(markdown)
    fragment = Nokogiri::HTML5.fragment(rendered)

    assert_empty fragment.css("script, iframe, [onclick], [onerror]")
    assert_empty fragment.css("a[href^='javascript:'], img[src^='data:']")
    assert_select fragment, "img[src='x']", count: 1
    assert_includes rendered, "alert('script')"
  end

  test "markdown_format cannot disable its safety options" do
    rendered = markdown_format("[mal](javascript:alert(1))", safe_links_only: false)
    fragment = Nokogiri::HTML5.fragment(rendered)

    assert_empty fragment.css("a[href^='javascript:']")
  end
end
