# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations, :inverse_of => :account
  field :username
  validates_presence_of :username
  validate :login
  field :encrypted_password
  field :active, :type => Boolean, :default => false
  scope :active, where(active: true)

  after_create { NYX_PROXY.add_account self; Resque.enqueue(AccountAdder, id)}

  def login
    begin
      Net::SSH.start(Yetting.host, username, :password => self.password, :timeout => 2)
    rescue
      errors.add(:username, "can't login to host")
    end
  end

  def password=(pass)
    if pass == "" || pass == nil
      errors.add(:password, "can't be empty")
    else
      self.update_attributes(:encrypted_password => pass.encrypt(:symmetric, :password => SECRET_KEY))
    end
  end

  def password
    if self.encrypted_password == nil
      ''
    else
      self.encrypted_password.decrypt(:symmetric, :password => SECRET_KEY)
    end
  end
end
