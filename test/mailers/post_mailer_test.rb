require 'test_helper'

class PostMailerTest < ActionMailer::TestCase
  test 'new_contribution' do
    mail = PostMailer.with(post: post(:contributed)).new_contribution
    assert_equal 'Hay una nueva contribución', mail.subject
    assert_equal ['juan@schwindt.org'], mail.to
    assert_equal ['no-responder@venganzasdelpasado.com.ar'], mail.from
    assert_match 'Hay una nueva contribuci', mail.body.encoded
  end
end
