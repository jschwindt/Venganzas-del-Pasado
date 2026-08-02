module AudioPipeline
  class SummaryService
    def initialize(audio:, content:)
      @audio = audio
      @content = content.to_s.strip
      raise InvalidRequest, "content no puede estar vacío" if @content.blank?
    end

    def call
      @audio.post.with_lock do
        current = @audio.post.content.to_s
        if current.blank?
          @audio.post.update!(content: @content)
        elsif current != @content
          raise Conflict, "el Post contiene un resumen manual o diferente"
        end
      end
      @audio.post
    end
  end
end
