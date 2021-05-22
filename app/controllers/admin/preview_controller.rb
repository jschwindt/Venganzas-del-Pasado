module Admin
  class PreviewController < BaseController
    def index
      @audios = AudioPreviewService.new params[:date]
    end
  end
end
