require 'test_helper'

class PostMailerTest < ActionMailer::TestCase
  test "new_contribution" do
    mail = PostMailer.new_contribution
    assert_equal "New contribution", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
