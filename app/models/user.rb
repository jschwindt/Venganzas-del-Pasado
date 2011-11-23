class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :alias, :use => :slugged
  has_many :comments, :dependent => :nullify
  validates :alias, :presence => true, :uniqueness => { :case_sensitive => false }
  before_save :update_gravatar_hash

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, # :confirmable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :alias

  def self.find_for_facebook_oauth(access_token, signed_in_resource=nil)
    data = access_token.extra.raw_info
    if user = User.find_by_email(data.email)
      user
    else # Create a user with a stub password. 
      generated_password = Devise.friendly_token.first(10)
      user = User.new( :email => data.email,
                  :password   => generated_password,
                  :password_confirmation => generated_password,
                  :alias      => data.username || data.name,
              )
      user.fb_userid = data.id
      user.save!
      user
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["user_hash"]
        user.email = data["email"]
      end
    end
  end

  private

  def update_gravatar_hash
    if email_changed?
      self.gravatar_hash = Digest::MD5.hexdigest(email.strip.downcase)
    end
  end
end
