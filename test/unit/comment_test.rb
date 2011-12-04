require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  should belong_to(:post)
  should belong_to(:user)
  should validate_presence_of(:content)

  test "should be valid" do
    assert comments(:one).valid?
  end

end
