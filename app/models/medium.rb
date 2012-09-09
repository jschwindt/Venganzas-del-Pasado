class Medium < ActiveRecord::Base
  mount_uploader :asset, MediaUploader

  validates :asset, :presence => true
end
