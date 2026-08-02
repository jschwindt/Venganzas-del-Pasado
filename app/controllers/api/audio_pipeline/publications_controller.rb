module Api
  module AudioPipeline
    class PublicationsController < BaseController
      def create
        result = ::AudioPipeline::PublicationService.new(**publication_params.to_h.symbolize_keys).call
        render(json: serialize(result), status: :created)
      end

      private

      def publication_params
        params.expect(
          publication: %i[show_date relative_path bytes duration_seconds sha256 source]
        )
      rescue ActionController::ParameterMissing
        params.permit(:show_date, :relative_path, :bytes, :duration_seconds, :sha256, :source)
      end

      def serialize(result)
        { post_id: result.post.id, audio_id: result.audio.id, url: result.url }
      end
    end
  end
end
