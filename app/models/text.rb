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
    def bulk_insert(audio_id, text)
      Text.where(audio_id: audio_id).destroy_all
      saved_lines = 0
      text.each_line do |line|
        time, text = line.split('|')
        text.strip!
        time = time.to_i
        if time > 0 && time < 7500 && text.length > 4
          Text.create(audio_id: audio_id, time: time, text: text)
          saved_lines += 1
        end
      end
      saved_lines
    end

    def speech_to_text(audio_id)
      audio = Audio.find(audio_id)
      return unless md = audio.url.match(%r((/\d{4}/[^\/]+\.mp3)))

      mp3_file = "#{Rails.application.config.x.audios_root}#{md[1]}"
      cmd = "#{Rails.application.config.x.speech_to_text_cmd} #{mp3_file}"
      puts "Audio: #{audio.id}, cmd: #{cmd}"
      Open3.popen3(cmd) do |_stdin, stdout, _stderr, wait_thr|
        saved_lines = bulk_insert(audio.id, stdout)
        exit_status = wait_thr.value
        puts("Status: #{exit_status}, created #{saved_lines} text lines.")
      end
    end
  end
end
