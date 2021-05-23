module Admin
  class PreviewController < BaseController
    def index
      @audios = AudioPreviewService.new params[:date]
    end

    def publish
      filename = params[:filename].gsub(%r{[^\w\d./_\-]}, '')
      if File.exist?(VenganzasDelPasado::Application.config.x.audios_root + filename)
        File.open("#{VenganzasDelPasado::Application.config.x.audios_root}/publish/#{Time.now.to_i}.txt", 'w') do |f|
          f.write filename
        end
        @result = "El archivo #{filename} será publicado."
      else
        @result = 'NOK'
      end
    end
  end
end
