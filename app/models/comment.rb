class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  
  validates :content, :presence => true
  
end
