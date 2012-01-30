class User
  include Mongoid::Document
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
  validates_presence_of :email, :password
  validates_uniqueness_of :email
  
  before_save :ensure_authentication_token
end
