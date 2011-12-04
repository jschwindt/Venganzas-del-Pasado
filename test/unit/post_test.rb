require 'test_helper'

class PostTest < ActiveSupport::TestCase

  should have_many(:comments).dependent(:destroy)
  should have_many(:audios).dependent(:destroy)
  should validate_presence_of(:title)

  test "should be valid" do
    assert posts(:one).valid?
  end

end
