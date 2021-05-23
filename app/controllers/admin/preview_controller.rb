module Admin
  class PreviewController < BaseController
    def index
      @audios = AudioPreviewService.new params[:date]
    end

    def publish
      filename = params[:filename].gsub(%r{[^\w\d./_\-]}, '')
      if File.exist?(VenganzasDelPasado::Application.config.x.audios_root + filename)
        File.open("#{VenganzasDelPasado::Application.config.x.audios_root}/publish/file.txt", 'w') do |f|
          f.write "#{filename}\n"
        end
        @result = "El archivo #{filename}"
      else
        @result = 'NOK'
      end
    end
  end
end
