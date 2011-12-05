class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  belongs_to :user

  validates :content, :presence => true

  scope :approved, where( :status => 'approved' )
  scope :pending,  where( :status => 'pending' )
  scope :fifo, order('created_at ASC')
  scope :lifo, order('created_at DESC')

  def self.approved_or_from_user( user )
    if user
      where( 'status = ? OR user_id = ?', 'approved', user.id )
    else
      approved
    end
  end

end
