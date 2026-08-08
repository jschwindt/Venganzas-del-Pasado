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
end
