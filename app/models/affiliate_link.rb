require "metainspector"

class AffiliateLink < ApplicationRecord
  after_initialize :set_default_active, if: :new_record?

  validates :name, :product_url, :affiliate_url, presence: true

  scope :lifo, -> { order("created_at DESC") }

  class << self
    def metadata_for(url)
      page = ::MetaInspector.new(
        url,
        connection_timeout: 5,
        read_timeout: 5,
        retries: 1
      )

      {
        name: page.best_title.presence || page.title,
        product_url: page.url,
        image_url: page.images.best
      }
    end
  end

  private

  def set_default_active
    self.active = true if active.nil?
  end
end
