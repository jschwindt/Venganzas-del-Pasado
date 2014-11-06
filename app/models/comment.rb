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

  class << self
    def visible_by( user )
      if user
        where( 'status IN (?) OR (user_id = ? AND status != ?)', ['neutral', 'approved', 'flagged'], user.id, 'deleted' )
      else
        where( 'status IN (?)', ['neutral', 'approved', 'flagged'] )
      end
    end

    def has_status(status)
      where( 'status = ?', status ) unless status.nil?
    end
  end # Class methods

  def publish_as(user, request)
    self.user_id = user.id
    self.author = user.alias
    self.author_email = user.email
    self.author_ip = request.remote_ip

    unless user.can? :publish, self
      self.moderate
    end

    self.profile_picture_url = user.profile_picture_url

    self
  end

  def update_profile_picture_url
    if user.present?
      self.profile_picture_url = user.profile_picture_url
    else
      gravatar_hash = Digest::MD5.hexdigest(author_email.strip.downcase)
      self.profile_picture_url = "http://www.gravatar.com/avatar/#{gravatar_hash}?d=mm&s=50"
    end
    save
  end

  def opinion_count
    self.like_count + self.dislike_count
  end

  def opinions
    (self.likes + self.dislikes).sort {|x,y| x.created_at <=> y.created_at }
  end

end
