class Comment < ApplicationRecord
  include AASM

  belongs_to :post, counter_cache: true
  belongs_to :user

  delegate :title, to: :post, prefix: true
  delegate :capitalize, to: :status, prefix: true, allow_nil: true

  validates :content, :post_id, presence: true

  searchkick searchable: %i[author content], filterable: [:created_at], language: 'spanish'
  scope :search_import, -> { where('status IN (?)', %w[neutral approved flagged]) }

  def should_index?
    %w[neutral approved flagged].include? status
  end

  aasm column: :status do
    state :neutral, initial: true
    state :approved
    state :pending
    state :deleted
    state :flagged

    event :approve do
      transitions to: :approved, from: %i[pending flagged deleted approved]
    end

    event :moderate do
      transitions to: :pending, from: :neutral
    end

    event :flag do
      transitions to: :flagged, from: :neutral
    end

    event :trash do
      transitions to: :deleted, from: %i[neutral approved pending flagged]
    end
  end

  scope :fifo, -> { order('created_at ASC') }
  scope :lifo, -> { order('created_at DESC') }

  class << self
    def visible_by(user)
      if user
        where('status IN (?) OR (user_id = ? AND status != ?)', %w[neutral approved flagged], user.id, 'deleted')
      else
        where('status IN (?)', %w[neutral approved flagged])
      end
    end

    def has_status(status)
      where('status = ?', status) unless status.nil?
    end
  end # Class methods

  def publish_as(user, request)
    self.user_id = user.id
    self.author = user.alias
    self.author_email = user.email
    self.author_ip = request.remote_ip

    moderate unless user.can? :publish, self

    self.profile_picture_url = user.profile_picture_url

    self
  end

end
