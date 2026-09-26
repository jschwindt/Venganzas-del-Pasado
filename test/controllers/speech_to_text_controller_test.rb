require "test_helper"

class SpeechToTextControllerTest < ActionDispatch::IntegrationTest
  HEADERS = {
    accept: "application/json",
    authorization: "123456"
  }

  setup do
    @previous_audio_api_user_email = ENV["AUDIO_API_USER_EMAIL"]
    @previous_audio_api_secret_token = ENV["AUDIO_API_SECRET_TOKEN"]
    ENV["AUDIO_API_USER_EMAIL"] = users(:one).email
    ENV["AUDIO_API_SECRET_TOKEN"] = HEADERS.fetch(:authorization)
  end

  teardown do
    ENV["AUDIO_API_USER_EMAIL"] = @previous_audio_api_user_email
    ENV["AUDIO_API_SECRET_TOKEN"] = @previous_audio_api_secret_token
  end

  test "should not authorize without credentials" do
    get speech_to_text_next_url, headers: { accept: "application/json" }
    assert_response :unauthorized
  end

  test "should get next" do
    get speech_to_text_next_url, headers: HEADERS
    assert_response :success
  end

  test "should put start" do
    audio = audios(:one)
    put speech_to_text_start_url(id: audio), headers: HEADERS
    assert_response :success
  end

  test "should put update" do
    audio = audios(:one)
    put speech_to_text_update_url(id: audio, text: "{1} one", time: 1), headers: HEADERS
    assert_response :success
  end
end
