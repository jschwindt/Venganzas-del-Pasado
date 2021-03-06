class Audio < ApplicationRecord
  enum speech_to_text_status: %i[unavailable processing available]
  belongs_to :post

  has_many :texts, dependent: :destroy

  delegate :title, to: :post, prefix: true

  validates :url, presence: true, uniqueness: { case_sensitive: false }

  def torrent_url
    # Pasa de //venganzasdelpasado.com.ar/2011/lavenganza_2011-11-22[_90].mp3
    #       a    https://s3.amazonaws.com/s3.schwindt.org/dolina/2011/lavenganza_2011-11-22[_90].mp3?torrent
    # Las contribuciones de los usuarios tienen _id de media antes de .mp3
    url.sub %r[.*//venganzasdelpasado.com.ar(/\d{4}/lavenganza_\d{4}-\d{2}-\d{2}.*\.mp3)$],
            'https://s3.amazonaws.com/s3.schwindt.org/dolina\1?torrent'
  end

  def sp_url
    filename = url.sub %r[.*//venganzasdelpasado.com.ar/\d{4}/lavenganza_((\d{4})-\d{2}-\d{2}).*\.mp3$],
                       '/\2/lvstsp-\1.mp3'
    if File.exist?(VenganzasDelPasado::Application.config.x.audios_root + filename)
      "https://venganzasdelpasado.com.ar#{filename}"
    end
  end
end
