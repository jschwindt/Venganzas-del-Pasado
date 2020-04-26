class User < ApplicationRecord
  extend FriendlyId
  friendly_id :alias, use: %i[history finders]
  has_many :comments, dependent: :nullify
  has_many :contributions, class_name: 'Post', foreign_key: :contributor_id, dependent: :nullify
  validates :alias, presence: true, uniqueness: { case_sensitive: false }
  before_save :update_profile_picture_url, :clean_role
  delegate :can?, :cannot?, to: :ability

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable, :lockable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  scope :lifo, -> { order('created_at DESC') }

  class << self
    def roles
      ['', 'admin', 'editor', 'moderator']
    end

    def find_for_facebook_oauth(access_token, _signed_in_resource = nil)
      data = access_token.extra.raw_info
      if (user = User.where('email = ? OR fb_userid = ?', data.email, data.id).first)
        user.email     = data.email
        user.fb_userid = data.id
        user.confirmed_at = Time.zone.now
        user.save!
        user
      else
        create_from_facebook data
      end
    end

    def create_from_facebook(fb_data)
      generated_password = Devise.friendly_token.first(10)
      user = User.new(email: fb_data.email,
                      alias: fb_data.username || fb_data.name,
                      password: generated_password,
                      password_confirmation: generated_password)
      user.fb_userid = fb_data.id
      user.skip_confirmation!
      user.save
      user
    end

    # Called by Devise during User creation
    def new_with_session(params, session)
      super.tap do |user|
        if (data = session['devise.facebook_data']) && session['devise.facebook_data']['extra']['raw_info']
          user.email         = params[:email]
          user.alias         = params[:alias]
          user.fb_userid     = data['id']
          generated_password = Devise.friendly_token.first(10)
          user.password      = generated_password
          user.password_confirmation = generated_password
          user.skip_confirmation!
        end
      end
    end

    def active
      # Los usuarios migrados de WP tienen confirmed_at
      # pero no necesariamente last_sign_in_at
      where('last_sign_in_at IS NOT NULL OR confirmed_at IS NOT NULL')
    end

    def gravatar_url(email)
      "//www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.strip.downcase)}?d=mm&s=50"
    end
  end # End class methods

  # Overrides Devise method to allow non-password updates for Facebook users
  def update_with_password(params = {})
    if has_facebook_profile?
      params.delete(:current_password)
      update_without_password(params)
    else
      super
    end
  end

  def ability
    @ability ||= Ability.new(self)
  end

  def can_admin?
    %w[moderator editor admin].include? role
  end

  #  def active?
  #    last_sign_in_at.present? || confirmed_at.present?
  #  end

  def has_facebook_profile?
    fb_userid.present?
  end

  def profile_picture_url
    self[:profile_picture_url] || update_profile_picture_url
  end

  private

  def update_profile_picture_url
    if has_facebook_profile?
      self.profile_picture_url = "//graph.facebook.com/#{fb_userid}/picture"
    else
      self.profile_picture_url = User.gravatar_url(email)
    end
  end

  def clean_role
    self.role = '' unless User.roles.include? role
  end
end
