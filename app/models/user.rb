class User
  include Mongoid::Document
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  field :secret_key
  validates_presence_of :email, :password, :secret_key
  validate :secret_key_is_correct

  def secret_key_is_correct
    if(self.secret_key != SECRET_KEY)
      errors.add(:secret_key, "is incorrect.")
    end
  end

end
