require "test_helper"
require "tmpdir"
require "tempfile"

class AudioPipeline::PublicationServiceTest < ActiveSupport::TestCase
  setup do
    @previous_root = Rails.application.config.x.audios_root
    @previous_public_url = Rails.application.config.x.public_audio_base_url
    @root = Pathname.new(Dir.mktmpdir("vdp-audio-pipeline"))
    Rails.application.config.x.audios_root = @root.to_s
    Rails.application.config.x.public_audio_base_url = "https://venganzasdelpasado.com.ar"
    @show_date = Date.new(2026, 7, 31)
    @relative_path = "2026/lavenganza_2026-07-31.mp3"
    @file = @root.join(@relative_path)
    @file.dirname.mkpath
    @file.binwrite("valid mp3 fixture bytes")
    @expected_bytes = @file.size
    @expected_sha256 = Digest::SHA256.file(@file).hexdigest
  end

  teardown do
    Rails.application.config.x.audios_root = @previous_root
    Rails.application.config.x.public_audio_base_url = @previous_public_url
    FileUtils.remove_entry(@root)
  end

  test "verifies the shared file and creates Post and Audio idempotently" do
    result = nil
    assert_difference([ "Post.count", "Audio.count" ], 1) do
      result = service.call
    end
    assert_equal @show_date + 1.day, result.post.created_at.to_date
    assert_equal 3, result.post.created_at.hour
    assert result.audio.unavailable?
    assert_equal @file.size, result.audio.bytes

    assert_no_difference([ "Post.count", "Audio.count" ]) do
      service.call
    end
  end

  test "rejects traversal, missing files, altered size and checksum" do
    assert_raises(AudioPipeline::InvalidRequest) { service(relative_path: "../secret.mp3").call }
    @file.delete
    assert_raises(AudioPipeline::InvalidRequest) { service.call }
    @file.binwrite("changed")
    assert_raises(AudioPipeline::Conflict) { service.call }
    assert_raises(AudioPipeline::Conflict) { service(bytes: @file.size, sha256: "0" * 64).call }
  end

  test "rejects a canonical path whose symlink escapes audio_root" do
    outside = Tempfile.new([ "outside-audio", ".mp3" ])
    outside.binmode
    outside.write("outside")
    outside.flush
    @file.delete
    File.symlink(outside.path, @file)

    assert_raises(AudioPipeline::InvalidRequest) do
      service(
        bytes: File.size(outside.path),
        sha256: Digest::SHA256.file(outside.path).hexdigest
      ).call
    end
  ensure
    outside&.close!
  end

  private

  def service(relative_path: @relative_path, bytes: @expected_bytes, sha256: @expected_sha256)
    AudioPipeline::PublicationService.new(
      show_date: @show_date.iso8601,
      relative_path:,
      bytes:,
      duration_seconds: 7045.54,
      sha256:,
      source: "radiocut-am750"
    )
  end
end
