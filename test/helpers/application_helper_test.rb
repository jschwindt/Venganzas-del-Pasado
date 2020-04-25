require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'alert_message_for' do
    post = Post.new(status: 'published')
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
end
