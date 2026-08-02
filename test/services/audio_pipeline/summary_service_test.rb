require "test_helper"

class AudioPipeline::SummaryServiceTest < ActiveSupport::TestCase
  test "sets empty content and accepts an identical retry" do
    audio = audios(:one)
    audio.post.update!(content: "")
    service = AudioPipeline::SummaryService.new(audio:, content: "## Resumen")

    service.call
    assert_equal "## Resumen", audio.post.reload.content
    service.call
    assert_equal "## Resumen", audio.post.reload.content
  end

  test "rejects overwriting different manual content" do
    audio = audios(:one)
    audio.post.update!(content: "Manual")

    assert_raises(AudioPipeline::Conflict) do
      AudioPipeline::SummaryService.new(audio:, content: "Automático").call
    end
    assert_equal "Manual", audio.post.reload.content
  end
end
