module Api
  module AudioPipeline
    class AudiosController < BaseController
      before_action :load_audio

      def transcript
        ::AudioPipeline::TranscriptService.new(
          audio: @audio,
          blocks: request.request_parameters["blocks"]
        ).call
        render(json: { audio_id: @audio.id, speech_to_text_status: @audio.speech_to_text_status })
      end

      def summary
        post = ::AudioPipeline::SummaryService.new(
          audio: @audio,
          content: request.request_parameters["content"]
        ).call
        render(json: { post_id: post.id, content: post.content })
      end

      private

      def load_audio
        @audio = Audio.find(params[:id])
      end
    end
  end
end
