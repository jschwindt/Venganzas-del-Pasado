module Api
  module AudioPipeline
    class ShowsController < BaseController
      def show
        result = ::AudioPipeline::ShowQuery.new(params[:date]).call
        render(json: serialize(result))
      end

      private

      def serialize(result)
        { post_id: result.post.id, audio_id: result.audio.id, url: result.url }
      end
    end
  end
end
