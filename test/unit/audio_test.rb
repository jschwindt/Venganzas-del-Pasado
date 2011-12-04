require 'test_helper'

class AudioTest < ActiveSupport::TestCase

  should belong_to(:post)
  should validate_presence_of(:url)

  test "should be valid" do
    assert audios(:one).valid?
  end

end
