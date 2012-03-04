class Medium < ActiveRecord::Base
  mount_uploader :asset, MediaUploader

  belongs_to :contributor, :class_name => 'User'
  validates :asset, :presence => true
end
