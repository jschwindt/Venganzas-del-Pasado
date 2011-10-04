class Post < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, :use => :slugged
  
  has_many :comments
  
  validates :title, :presence => true
  
end
