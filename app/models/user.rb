class User < ApplicationRecord
  extend FriendlyId
  friendly_id :alias, use: %i[history finders]
  has_many :comments, dependent: :nullify
  has_many :contributions, class_name: "Post", foreign_key: :contributor_id, dependent: :nullify
  validates :alias, presence: true, uniqueness: { case_sensitive: false }
  before_save :update_profile_picture_url, :clean_role
  delegate :can?, :cannot?, to: :ability

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable

  scope :lifo, -> { order("created_at DESC") }

  class << self
    def roles
      [ "", "admin", "editor", "moderator" ]
    end

    def active
      # Los usuarios migrados de WP tienen confirmed_at
      # pero no necesariamente last_sign_in_at
      where("last_sign_in_at IS NOT NULL OR confirmed_at IS NOT NULL")
    end

    def gravatar_url(email)
      "//www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.strip.downcase)}?d=mm&s=50"
    end
  end # End class methods

  def ability
    @ability ||= Ability.new(self)
  end

  def can_admin?
    %w[moderator editor admin].include? role
  end

  def profile_picture_url
    self[:profile_picture_url] || update_profile_picture_url
  end

  private

  def update_profile_picture_url
    self.profile_picture_url = User.gravatar_url(email)
  end

  def clean_role
    self.role = "" unless User.roles.include? role
  end
end
