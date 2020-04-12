class Medium < ApplicationRecord
  mount_uploader :asset, MediaUploader

  validates :asset, presence: true

end
