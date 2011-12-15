class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :alias, :use => :slugged
  has_many :comments, :dependent => :nullify
  validates :alias, :presence => true, :uniqueness => { :case_sensitive => false }
  before_save :update_gravatar_hash, :clean_role
  delegate :can?, :cannot?, :to => :ability

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :alias


  scope :lifo, order('created_at DESC')

  def self.roles
    ['', 'admin', 'editor', 'moderator']
  end

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.where('email = ? OR fb_userid = ?', data.email, data.id).first
      if user.email != data.email
        user.email = data.email
        user.save!
      end
      user
    else # Create a user with a stub password.
      generated_password = Devise.friendly_token.first(10)
      user = User.new( :email => data.email,
                  :alias      => data.username || data.name,
                  :password   => generated_password,
                  :password_confirmation => generated_password,
              )
      user.fb_userid = data.id
      user.skip_confirmation!
      user.save
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email         = params[:email]
        user.alias         = params[:alias]
        user.fb_userid     = data["id"]
        generated_password = Devise.friendly_token.first(10)
        user.password      = generated_password
        user.password_confirmation = generated_password
        user.skip_confirmation!
      end
    end
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def can_admin?
    ['moderator','editor','admin'].include? role
  end

  def active?
    last_sign_in_at.present? || confirmed_at.present?
  end

  def self.active
    # Los usuarios migrados de WP tienen confirmed_ar
    # pero no necesariamente last_sign_in_at
    where('last_sign_in_at IS NOT NULL OR confirmed_at IS NOT NULL')
  end

  def has_facebook_profile?
    self.fb_userid.present?
  end

  def facebook_profile_url
    unless self.fb_userid.blank?
      'http://www.facebook.com/profile.php?id=' + self.fb_userid
    end
  end

  private

  def update_gravatar_hash
    if email_changed?
      self.gravatar_hash = Digest::MD5.hexdigest(email.strip.downcase)
    end
  end

  def clean_role
    self.role = '' unless User.roles.include? self.role
  end
end
