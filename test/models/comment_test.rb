require "test_helper"

class CommentTest < ActiveSupport::TestCase
  Request = Data.define(:remote_ip)

  test "publish_as" do
    user = users(:one)
    request = Request.new(remote_ip: "192.168.0.10")
    comment = posts(:published).comments.new(content: "hola").publish_as user, request
    assert comment.valid?
    assert_equal comment.status, "pending"
  end

  test "publish_as as neutral" do
    user = users(:good_karma)
    request = Request.new(remote_ip: "192.168.0.10")
    comment = posts(:published).comments.new(content: "hola").publish_as user, request
    assert comment.valid?
    assert_equal comment.status, "neutral"
  end
end
