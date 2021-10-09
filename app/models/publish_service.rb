class PublishService
  def initialize
    @publish_files = Dir["#{VenganzasDelPasado::Application.config.x.audios_root}/publish/*.txt"]
  end

  def run
    @publish_files.each do |publish_file|
      File.readlines(publish_file).each do |line|
        if line.match(%r[(/st\d/)(lavenganza_(\d{4})-\d{2}-\d{2}.mp3)])
          process(Regexp.last_match(0), Regexp.last_match(2), Regexp.last_match(3))
        end
      end
    end
    FileUtils.rm @publish_files
  end

  def process(source_mp3_file, mp3_file_name, year)
    return unless File.exist?("#{VenganzasDelPasado::Application.config.x.audios_root}#{source_mp3_file}")

    copy_mp3(source_mp3_file, year)
    create_post("#{VenganzasDelPasado::Application.config.x.audios_root}/#{year}/#{mp3_file_name}")
    sync_s3(year)
    generate_sitemap
  end

  def copy_mp3(source_mp3_file, year)
    source = "#{VenganzasDelPasado::Application.config.x.audios_root}#{source_mp3_file}"
    dest = "#{VenganzasDelPasado::Application.config.x.audios_root}/#{year}/"
    puts "Copying #{source} -> #{dest}"
    FileUtils.cp(source, dest)
  end

  def create_post(audio_file)
    post = Post.create_from_audio_file(audio_file)
    audio = post.audios.first
    file_size = File.size audio_file
    audio.update(bytes: file_size, speech_to_text_status: :unavailable)
    puts "#{post.inspect}\n#{audio.inspect}"
  end

  def sync_s3(year)
    source = "#{VenganzasDelPasado::Application.config.x.audios_root}/#{year}/"
    dest = "s3://s3.schwindt.org/dolina/#{year}/"
    result = `aws s3 sync #{source} #{dest} --acl public-read --no-progress`
    puts result if result.present?
  end

  def generate_sitemap
    Rails.application.load_tasks
    Rake::Task['sitemap:refresh'].invoke
  end
end
