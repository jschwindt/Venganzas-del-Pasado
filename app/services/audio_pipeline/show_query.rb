module AudioPipeline
  class ShowQuery
    Result = Data.define(:post, :audio, :url)

    def initialize(show_date)
      @show_date = Date.iso8601(show_date.to_s)
      raise ArgumentError unless @show_date.iso8601 == show_date.to_s
    rescue ArgumentError
      raise InvalidRequest, "date debe tener formato YYYY-MM-DD"
    end

    def call
      audio = Audio.includes(:post).find_by(url: public_audio_url)
      raise ActiveRecord::RecordNotFound if audio.nil?

      Result.new(post: audio.post, audio:, url: post_url(audio.post))
    end

    private

    def public_audio_url
      base = Rails.application.config.x.public_audio_base_url.to_s.delete_suffix("/")
      "#{base}/#{@show_date.year}/lavenganza_#{@show_date.iso8601}.mp3"
    end

    def post_url(post)
      base = URI.parse(Rails.application.config.x.public_audio_base_url.to_s)
      Rails.application.routes.url_helpers.post_url(post, host: base.host, protocol: base.scheme)
    end
  end
end
