require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test "moderation_needed" do
    mail = CommentMailer.moderation_needed
    assert_equal "Moderation needed", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
