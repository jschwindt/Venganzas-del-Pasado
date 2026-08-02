require "test_helper"

class AudioPipeline::TranscriptServiceTest < ActiveSupport::TestCase
  test "replaces all blocks transactionally and marks audio available" do
    audio = audios(:one)
    audio.texts.create!(time: 99, text: "old")

    AudioPipeline::TranscriptService.new(
      audio:,
      blocks: [ { time: 0, text: "first" }, { time: 300, text: "second" } ]
    ).call

    assert_equal [ [ 0, "first" ], [ 300, "second" ] ], audio.texts.order(:time).pluck(:time, :text)
    assert audio.reload.available?
  end

  test "rolls back when any block is invalid" do
    audio = audios(:one)
    original = audio.texts.pluck(:time, :text)

    assert_raises(AudioPipeline::InvalidRequest) do
      AudioPipeline::TranscriptService.new(
        audio:,
        blocks: [ { time: 0, text: "valid" }, { time: -1, text: "invalid" } ]
      ).call
    end

    assert_equal original, audio.texts.pluck(:time, :text)
  end
end
