require 'test_helper'

class AudioTest < ActiveSupport::TestCase
  test 'create audio' do
    assert_difference 'Audio.count' do
      Audio.create(url: 'http://example.com/new.mp3', post: posts(:one))
    end
  end

  test 'create audio validations' do
    assert_no_difference 'Audio.count' do
      audio = Audio.create
      assert audio.errors.messages[:post].present?
      assert audio.errors.messages[:url].present?
    end
  end

  test 'create audio with repeated url' do
    assert_no_difference 'Audio.count' do
      audio = Audio.create(url: 'http://example.com/test.mp3', post: posts(:one))
      assert_equal audio.errors.details[:url][0][:error], :taken
    end
  end

end
