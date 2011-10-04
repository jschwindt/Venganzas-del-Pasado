class Comment < ActiveRecord::Base
  belongs_to :post
  
  validates :content, :presence => true
  
end
