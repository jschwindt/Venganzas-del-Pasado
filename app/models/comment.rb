class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  belongs_to :user

  validates :content, :presence => true

  scope :approved, where(:status => 'approved')
  scope :fifo, order('created_at ASC')

end
