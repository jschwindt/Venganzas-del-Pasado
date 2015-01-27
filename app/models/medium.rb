class Medium < ActiveRecord::Base
  mount_uploader :asset, MediaUploader

  validates :asset, :presence => true

  attr_accessible :asset

end
