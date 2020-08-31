class SpeechToTextController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_user_from_token!
  before_action :authenticate_user!
  before_action :load_audio, only: [:start, :update]

  def next
    audios = Audio.where(speech_to_text_status: :not_available).order(id: :desc).limit(3)
    render json: audios.to_json
  end

  def start
    @audio.processing!
    render json: @audio.to_json
  end

  def update
    inserted_lines = Text.bulk_insert(@audio.id, request.body)
    if inserted_lines > 0
      @audio.available!
    end
    render json: @audio.to_json
  end

  private

  def authenticate_user_from_token!
    user_email = Rails.application.credentials.audio_api[:user_email]
    secret_token = Rails.application.credentials.audio_api[:secret_token]
    user = user_email && User.find_by_email(user_email)
    if user && Devise.secure_compare(secret_token, request.headers[:authorization])
      sign_in user, store: false
    end
  end

  def load_audio
    @audio = Audio.find(params[:id])
  end
end
