class AddSpeechToTextStatusToAudios < ActiveRecord::Migration[6.0]
  def change
    add_column :audios, :speech_to_text_status, :integer, default: 0
  end
end
