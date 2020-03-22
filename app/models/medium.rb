class Medium < ApplicationRecord
  mount_uploader :asset, MediaUploader

  validates :asset, :presence => true

  # TODO: Rails6
  # attr_accessible :asset

end
