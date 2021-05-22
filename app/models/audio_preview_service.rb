class AudioPreviewService
  include Enumerable
  attr_reader :date_str, :mp3_file

  def initialize(date_str = nil)
    @date_str = date_str
    @date_str = (Date.today - 1).strftime('%Y-%m-%d') unless date_str.present?
    @mp3_file = "lavenganza_#{@date_str}.mp3"
  end

  def each
    VenganzasDelPasado::Application.config.x.audios_folders.each do |folder|
      file = VenganzasDelPasado::Application.config.x.audios_root + folder + mp3_file
      next unless File.exist? file

      yield({ folder: folder, file: mp3_file, size: File.stat(file).size })
    end
  end
end
