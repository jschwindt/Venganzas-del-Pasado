require 'open3'

class Text < ApplicationRecord
  belongs_to :audio

  searchkick searchable: %i[text], settings: {
    analysis: {
      filter: {
        spanish_stop: {
          type: 'stop',
          stopwords: '_spanish_'
        }
      },
      analyzer: {
        rebuilt_spanish: {
          tokenizer: 'standard',
          filter: %w[asciifolding spanish_stop]
        }
      }
    }
  }

  # Class methods
  class << self
    def speech_to_text(audio_id)

      audio = Audio.find(audio_id)
      return unless md = audio.url.match(%r((/\d{4}/[^\/]+\.mp3)))

      mp3_file = " /var/www/venganzasdelpasado.com.ar#{md[1]}"
      cmd = "~/speech_to_text.py --model ~/vosk-model-es --audio #{mp3_file}"
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line=stdout.gets do 
          time, text = line.split('|')
          time = time.to_i
          if time > 0 && time < 7500
            Text.create(audio_id: audio_id, time: time, text: text)
          end
        end
      end
    end
  end
end
