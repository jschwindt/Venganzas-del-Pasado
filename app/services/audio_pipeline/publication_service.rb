require "digest"
require "pathname"
require "uri"

module AudioPipeline
  class PublicationService
    Result = Data.define(:post, :audio, :url)

    def initialize(show_date:, relative_path:, bytes:, duration_seconds:, sha256:, source:)
      @show_date = parse_date(show_date)
      @relative_path = relative_path.to_s
      @bytes = parse_positive_integer(bytes, "bytes")
      @duration_seconds = parse_positive_float(duration_seconds, "duration_seconds")
      @sha256 = parse_sha256(sha256)
      @source = source.to_s
    end

    def call
      validate_source!
      audio_file = resolve_audio_file
      verify_audio_file!(audio_file)
      post, audio = create_or_find_records
      RefreshDerivedOutputs.call(post)
      Result.new(post:, audio:, url: post_url(post))
    end

    private

    def parse_date(value)
      parsed = Date.iso8601(value.to_s)
      raise ArgumentError unless parsed.iso8601 == value.to_s

      parsed
    rescue ArgumentError
      raise InvalidRequest, "show_date debe tener formato YYYY-MM-DD"
    end

    def parse_positive_integer(value, name)
      parsed = Integer(value)
      raise ArgumentError unless parsed.positive?

      parsed
    rescue ArgumentError, TypeError
      raise InvalidRequest, "#{name} debe ser un entero positivo"
    end

    def parse_positive_float(value, name)
      parsed = Float(value)
      raise ArgumentError unless parsed.positive? && parsed.finite?

      parsed
    rescue ArgumentError, TypeError
      raise InvalidRequest, "#{name} debe ser un número positivo"
    end

    def parse_sha256(value)
      parsed = value.to_s.downcase
      raise InvalidRequest, "sha256 inválido" unless parsed.match?(/\A[0-9a-f]{64}\z/)

      parsed
    end

    def validate_source!
      raise InvalidRequest, "source no puede estar vacío" if @source.blank?
    end

    def expected_relative_path
      "#{@show_date.year}/lavenganza_#{@show_date.iso8601}.mp3"
    end

    def resolve_audio_file
      relative = Pathname.new(@relative_path)
      if relative.absolute? || @relative_path != expected_relative_path
        raise InvalidRequest, "relative_path no es el nombre canónico esperado"
      end

      root = Pathname.new(Rails.application.config.x.audios_root.to_s)
      raise InvalidRequest, "audio_root no existe" unless root.directory?

      candidate = root.join(relative)
      raise InvalidRequest, "el MP3 publicado no existe" unless candidate.file?

      resolved_root = root.realpath
      resolved_candidate = candidate.realpath
      resolved_relative = resolved_candidate.relative_path_from(resolved_root)
      if resolved_relative.each_filename.first == ".."
        raise InvalidRequest, "relative_path queda fuera de audio_root"
      end
      resolved_candidate
    rescue ArgumentError
      raise InvalidRequest, "relative_path queda fuera de audio_root"
    rescue Errno::ENOENT, Errno::EACCES => error
      raise InvalidRequest, "no se pudo resolver el MP3: #{error.message}"
    end

    def verify_audio_file!(audio_file)
      actual_bytes = audio_file.size
      if actual_bytes != @bytes
        raise Conflict, "bytes no coincide: #{actual_bytes} != #{@bytes}"
      end

      actual_sha256 = Digest::SHA256.file(audio_file).hexdigest
      return if ActiveSupport::SecurityUtils.secure_compare(actual_sha256, @sha256)

      raise Conflict, "sha256 no coincide con el archivo publicado"
    end

    def create_or_find_records
      post = nil
      audio = nil
      Post.transaction do
        post = Post.find_or_initialize_by(title: title)
        if post.new_record?
          post.status = "published"
          post.content = ""
          post.created_at = publication_time
          post.save!
        end

        audio = Audio.find_or_initialize_by(url: public_audio_url)
        if audio.persisted? && audio.post_id != post.id
          raise Conflict, "el Audio canónico pertenece a otro Post"
        end
        if audio.new_record?
          audio.post = post
          audio.bytes = @bytes
          audio.speech_to_text_status = :unavailable
          audio.save!
        elsif audio.bytes != @bytes
          audio.update!(bytes: @bytes)
        end
      end
      [ post, audio ]
    end

    def title
      "La venganza será terrible del #{@show_date.strftime("%d/%m/%Y")}"
    end

    def publication_time
      Time.zone.local(@show_date.year, @show_date.month, @show_date.day, 3).advance(days: 1)
    end

    def public_audio_url
      base = Rails.application.config.x.public_audio_base_url.to_s.delete_suffix("/")
      "#{base}/#{expected_relative_path}"
    end

    def post_url(post)
      Rails.application.routes.url_helpers.post_url(
        post,
        host: URI.parse(Rails.application.config.x.public_audio_base_url.to_s).host,
        protocol: URI.parse(Rails.application.config.x.public_audio_base_url.to_s).scheme
      )
    end
  end
end
