namespace :vdp do
  desc 'Publica contribuciones'
  namespace :contribuciones do
    task publish: :environment do
      Post.waiting.each(&:publish_contribution)
      CarrierWave.clean_cached_files!
    end
  end

  class TextBlock
    attr_reader :text, :block_time

    def initialize
      @block_time = 0
      @line_time = 0
      @text = ''
    end

    def add(time, text)
      @block_time = time if @block_time.zero?

      if @line_time.zero?
        @text += "{#{time}} #{text}"
        @line_time = time
      else
        if (time - @line_time) <= 10
          @text += " #{text}"
        else
          @text += "\n{#{time}} #{text}"
          @line_time = time
        end
      end
      time - @block_time
    end

    def close
      @text += "\n"
    end
  end

  def reformat_text(audio_id)
    blocks = []
    current_tb = nil

    Text.where(audio_id: audio_id).order(time: :asc).each do |text|
      next if text.text.length.zero?
      next if text.text.starts_with?('{')

      current_tb = TextBlock.new if current_tb.nil?
      block_duration = current_tb.add(text.time, text.text)
      if block_duration > 300
        current_tb.close
        blocks << current_tb
        current_tb = nil
      end
    end

    if current_tb
      current_tb.close
      blocks << current_tb
    end

    return if blocks.none?

    Text.where(audio_id: audio_id).delete_all
    blocks.each do |block|
      Text.create(audio_id: audio_id, time: block.block_time, text: block.text)
    end
    puts audio_id
  end

  desc 'Refactor texts'
  namespace :text do
    task refactor: :environment do
      Text.select(:audio_id).group(:audio_id).each do |t|
        reformat_text t.audio_id
      end
    end
  end
end
