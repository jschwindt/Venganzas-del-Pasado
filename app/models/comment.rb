class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  belongs_to :user

  validates :content, :presence => true

  scope :approved, where( :status => 'approved' )
  scope :fifo, order('created_at ASC')

  def self.approved_or_from_user( user )
    if user
      where( 'status = ? OR user_id = ?', 'approved', user.id )
    else
      approved
    end
  end

  def publish_as(user, request)
    self.user_id = user.id
    self.author = user.alias
    self.author_email = user.email
    self.author_ip = request.remote_ip

    if user.can? :approve, self
      self.status =  'approved'
    else
      self.status = 'pending'
    end

    self.gravatar_hash = user.gravatar_hash
  end

end
