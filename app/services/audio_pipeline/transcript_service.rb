module AudioPipeline
  class TranscriptService
    def initialize(audio:, blocks:)
      @audio = audio
      @blocks = normalize_blocks(blocks)
    end

    def call
      Audio.transaction do
        @audio.lock!
        @audio.texts.delete_all
        @blocks.each { |block| @audio.texts.create!(time: block[:time], text: block[:text]) }
        @audio.available!
      end
      @audio
    end

    private

    def normalize_blocks(blocks)
      raise InvalidRequest, "blocks debe ser una lista no vacía" unless blocks.is_a?(Array) && blocks.any?

      blocks.map do |block|
        raise InvalidRequest, "cada bloque debe ser un objeto" unless block.respond_to?(:to_h)

        values = block.to_h.stringify_keys
        time = Integer(values.fetch("time"))
        text = values.fetch("text").to_s.strip
        raise InvalidRequest, "time debe ser mayor o igual a cero" if time.negative?
        raise InvalidRequest, "text no puede estar vacío" if text.blank?

        { time:, text: }
      rescue KeyError, ArgumentError, TypeError
        raise InvalidRequest, "cada bloque requiere time entero y text"
      end
    end
  end
end
