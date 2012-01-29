class Media < ActiveRecord::Base
  mount_uploader :asset, MediaUploader

  validates :name, :asset, :presence => true
end
