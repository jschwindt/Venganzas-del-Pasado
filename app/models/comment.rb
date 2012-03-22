class Comment < ActiveRecord::Base
  include AASM
  include Likeable

  belongs_to :post, :counter_cache => true
  belongs_to :user

  delegate :title, :to => :post, :prefix => true

  # Warning: los siguientes son los únicos attributos accesibles con asignación masiva
  attr_accessible :content
  attr_accessible :status, :as => :admin

  validates :content, :post_id, :presence => true

  aasm :column => :status do
    state :neutral, :initial => true
    state :approved
    state :pending
    state :deleted
    state :flagged

    event :approve do
      transitions :to => :approved, :from => [:pending, :flagged, :deleted]
    end

    event :moderate do
      transitions :to => :pending, :from => :neutral
    end

    event :flag do
      transitions :to => :flagged, :from => :neutral
    end

    event :trash do
      transitions :to => :deleted, :from => [:neutral, :approved, :pending, :flagged]
    end

  end

  scope :fifo, order('created_at ASC')
  scope :lifo, order('created_at DESC')

  def self.visible_by( user )
    if user
      where( 'status IN (?) OR (user_id = ? AND status != ?)', ['neutral', 'approved', 'flagged'], user.id, 'deleted' )
    else
      where( 'status IN (?)', ['neutral', 'approved', 'flagged'] )
    end
  end

  def publish_as(user, request)
    self.user_id = user.id
    self.author = user.alias
    self.author_email = user.email
    self.author_ip = request.remote_ip

    unless user.can? :publish, self
      self.moderate
    end

    self.gravatar_hash = user.gravatar_hash

    self
  end

  def self.has_status(status)
    where( 'status = ?', status ) unless status.nil?
  end

  define_index do
    indexes content
    indexex author
    has created_at
    where "status IN ('neutral', 'approved', 'flagged')"
  end

end
