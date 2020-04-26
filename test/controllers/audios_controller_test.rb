require 'test_helper'

class AudiosControllerTest < ActionDispatch::IntegrationTest
  test 'should show audio popup' do
    audio = audios(:real_url)
    get post_audio_url(audio.post, audio)
    assert_response :success
  end
end
