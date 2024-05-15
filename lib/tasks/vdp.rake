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

  desc 'Publica contribuciones desde planilla'
  namespace :contribuciones do
    task :from_xls, [:xls_file] => [:environment] do |task, args|
      s = SimpleSpreadsheet::Workbook.read(args[:xls_file])
      s.selected_sheet = s.sheets.first
      s.first_row.upto(s.last_row) do |line|
        next if line == 1
        title = s.cell(line, 1)
        date = s.cell(line, 2)
        file = s.cell(line, 3)
        podcast = s.cell(line, 5)
        new_title = s.cell(line, 6)
        wikipedia = s.cell(line, 7)
        next if podcast.blank?

        audio = Audio.where("url LIKE ?", "%#{file}").first
        if audio.nil? || audio.post.nil?
          puts "Audio not found"
          next
        end

        post = audio.post
        post.title = new_title if new_title.present?

        if wikipedia.present? && wikipedia.starts_with?('https://')
          begin
            response = HTTPX.head(wikipedia)
            if response.status == 200
              post.content += "[#{wikipedia}](#{wikipedia})"
            end
          rescue
            puts "Error fetching #{wikipedia}"
          end

        end

        post.save
        puts "Updated line #{line} #{post.id}:#{post.title}"
        # exit 1
        # dt = DateTime.new(date.year, date.month, date.day, 7, 0, 0, Rational(-3,24))
        # file = date.strftime("%Y/%m/#{s.cell(line, 3)}")
        # full_path = "#{args[:mp3_path]}/#{file}"
        # if File.exist?(full_path)
        #   print "Publishing #{title} from #{file} #{File.size(full_path)} (#{dt})"

        #   audio       = Audio.find_or_initialize_by(url: "https://venganzasdelpasado.com.ar/#{file}")
        #   audio.bytes = File.size(full_path)

        #   if audio.new_record?
        #     post = Post.create do |post|
        #       post.title      = title
        #       post.created_at = dt
        #       post.status     = 'published'
        #       post.content    = ''
        #       post.contributor_id = args[:contributor_id]
        #       post.audios << audio
        #     end

        #     if post.persisted?
        #       puts " ✓"
        #     else
        #       puts " ❌  #{post.errors.full_messages}"
        #     end
        #   else
        #     puts " ⚠️  Already exists"
        #   end

        # else
        #   puts "File not found #{full_path}"
        # end

      end
    end
  end

end
