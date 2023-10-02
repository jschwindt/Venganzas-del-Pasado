class Audio < ApplicationRecord
  enum speech_to_text_status: %i[unavailable processing available]
  belongs_to :post

  has_many :texts, dependent: :destroy

  delegate :title, to: :post, prefix: true

  validates :url, presence: true, uniqueness: { case_sensitive: false }

  def sp_url
    filename = url.sub %r[.*//venganzasdelpasado.com.ar/\d{4}/lavenganza_((\d{4})-\d{2}-\d{2}).*\.mp3$],
                       '/\2/lvstsp-\1.mp3'
    if File.exist?(VenganzasDelPasado::Application.config.x.audios_root + filename)
      "https://venganzasdelpasado.com.ar#{filename}"
    end
  end
end
