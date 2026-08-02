require "digest"

module Api
  module AudioPipeline
    class BaseController < ActionController::API
      before_action :authenticate_pipeline!

      rescue_from ::AudioPipeline::InvalidRequest do |error|
        render(json: { error: error.message }, status: :unprocessable_entity)
      end
      rescue_from ::AudioPipeline::Conflict do |error|
        render(json: { error: error.message }, status: :conflict)
      end
      rescue_from ActiveRecord::RecordNotFound do
        render(json: { error: "not found" }, status: :not_found)
      end

      private

      def authenticate_pipeline!
        expected = ENV["VDP_AUDIO_PIPELINE_API_TOKEN"].to_s
        provided = request.authorization.to_s.delete_prefix("Bearer ")
        expected_digest = Digest::SHA256.hexdigest(expected)
        provided_digest = Digest::SHA256.hexdigest(provided)
        return if expected.present? && ActiveSupport::SecurityUtils.secure_compare(expected_digest, provided_digest)

        head(:unauthorized)
      end
    end
  end
end
