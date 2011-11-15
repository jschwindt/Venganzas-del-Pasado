class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :alias, :use => :slugged

  has_many :comments, :dependent => :nullify

  validates :alias, :presence => true, :uniqueness => { :case_sensitive => false }

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :alias

end
