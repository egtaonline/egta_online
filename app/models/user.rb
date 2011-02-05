class User
  include Mongoid::Document

  field :admin, :type => Boolean

  validates_presence_of :email
  validates_uniqueness_of :email, :case_sensitive => false

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable
end
