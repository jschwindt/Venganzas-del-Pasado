class Audio < ActiveRecord::Base
  belongs_to :post

  validates :url, :presence => true
end
