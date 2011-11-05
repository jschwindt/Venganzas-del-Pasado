class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged
  
  has_many :comments, :dependent => :destroy
  has_many :audios,   :dependent => :destroy
  
  validates :title, :presence => true
  
end
