require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  test 'publish_as' do
    user = users(:one)
    request = { remote_id: '192.168.0.10' }.to_o
    comment = posts(:published).comments.new(content: 'hola').publish_as user, request
    assert comment.valid?
    assert_equal comment.status, 'pending'
  end

  test 'publish_as as neutral' do
    user = users(:good_karma)
    request = { remote_id: '192.168.0.10' }.to_o
    comment = posts(:published).comments.new(content: 'hola').publish_as user, request
    assert comment.valid?
    assert_equal comment.status, 'neutral'
  end

end
