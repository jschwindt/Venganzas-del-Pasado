require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test 'moderation_needed' do
    mail = CommentMailer.with(comment: comments(:one), subject: 'the subject').moderation_needed
    assert_equal 'the subject', mail.subject
    assert_equal ['juan@schwindt.org'], mail.to
    assert_equal ['no-responder@venganzasdelpasado.com.ar'], mail.from
    assert_match 'Hay un nuevo comentario para moderar', mail.body.encoded
  end
end
