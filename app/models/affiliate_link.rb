class AffiliateLink < ApplicationRecord
  validates :name, :product_url, :affiliate_url, presence: true

  scope :lifo, -> { order("created_at DESC") }
end
