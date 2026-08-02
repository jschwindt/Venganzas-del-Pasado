require "test_helper"
require "tmpdir"

class Api::AudioPipelineControllerTest < ActionDispatch::IntegrationTest
  setup do
    @previous_token = ENV["VDP_AUDIO_PIPELINE_API_TOKEN"]
    ENV["VDP_AUDIO_PIPELINE_API_TOKEN"] = "pipeline-secret"
    @headers = { authorization: "Bearer pipeline-secret", accept: "application/json" }
    @previous_root = Rails.application.config.x.audios_root
    @root = Pathname.new(Dir.mktmpdir("vdp-audio-pipeline-controller"))
    Rails.application.config.x.audios_root = @root.to_s
  end

  teardown do
    ENV["VDP_AUDIO_PIPELINE_API_TOKEN"] = @previous_token
    Rails.application.config.x.audios_root = @previous_root
    FileUtils.remove_entry(@root)
  end

  test "requires the dedicated bearer token" do
    get "/api/audio_pipeline/shows/2026-07-31", headers: { accept: "application/json" }
    assert_response :unauthorized
  end

  test "publication returns ids without receiving a file" do
    relative_path = "2030/lavenganza_2030-07-31.mp3"
    file = @root.join(relative_path)
    file.dirname.mkpath
    file.binwrite("shared audio")
    post "/api/audio_pipeline/publications",
      params: {
        show_date: "2030-07-31",
        relative_path:,
        bytes: file.size,
        duration_seconds: 1.0,
        sha256: Digest::SHA256.file(file).hexdigest,
        source: "test"
      },
      headers: @headers,
      as: :json

    assert_response :created
    assert Audio.exists?(response.parsed_body["audio_id"])
  end

  test "transcript and summary endpoints call their services" do
    audio = audios(:one)
    audio.post.update!(content: "")
    put "/api/audio_pipeline/audios/#{audio.id}/transcript",
      params: { blocks: [ { time: 0, text: "text" } ] }, headers: @headers, as: :json
    assert_response :success
    assert_equal [ [ 0, "text" ] ], audio.texts.reload.pluck(:time, :text)

    put "/api/audio_pipeline/audios/#{audio.id}/summary",
      params: { content: "summary" }, headers: @headers, as: :json
    assert_response :success
    assert_equal "summary", audio.post.reload.content
  end
end
