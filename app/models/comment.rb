class Comment < ActiveRecord::Base
  belongs_to :post, :counter_cache => true
  belongs_to :user

  # Warning: los siguientes son los únicos attributos accesibles con asignación masiva
  attr_accessible :content

  validates :content, :presence => true

  scope :approved, where( :status => 'approved' )
  scope :pending,  where( :status => 'pending' )
  scope :deleted,  where( :status => 'deleted' )
  scope :fifo, order('created_at ASC')
  scope :lifo, order('created_at DESC')

  def self.approved_or_from_user( user )
    if user
      where( 'status = ? OR (user_id = ? AND status != ?)', 'approved', user.id, 'deleted' )
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

    self
  end

  def approved?
    self.status == 'approved'
  end

  def pending?
    self.status == 'pending'
  end

  def deleted?
    self.status == 'deleted'
  end

end
