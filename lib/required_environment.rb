module RequiredEnvironment
  PRODUCTION_VARIABLES = %w[
    SECRET_KEY_BASE
    MEILISEARCH_API_KEY
    RECAPTCHA_SITE_KEY
    RECAPTCHA_SECRET_KEY
    AUDIO_API_USER_EMAIL
    AUDIO_API_SECRET_TOKEN
    VDP_AUDIO_PIPELINE_API_TOKEN
  ].freeze

  def self.validate!(environment:, values: ENV)
    return unless environment.to_s == "production"

    missing = PRODUCTION_VARIABLES.select { |name| values[name].to_s.empty? }
    return if missing.empty?

    raise KeyError, "Missing required production environment variables: #{missing.join(", ")}"
  end
end
