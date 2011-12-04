class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  belongs_to :user

  validates :content, :presence => true

  scope :approved, where( :status => 'approved' )
  scope :approved_or_from_user, lambda { |user|  where( 'status = ? OR user_id = ?', 'approved', user.id ) }
  scope :fifo, order('created_at ASC')

end
