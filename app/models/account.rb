# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations, :inverse_of => :account
  field :username
  field :max_concurrent_simulations, :type => Integer
  validates_presence_of :username, :max_concurrent_simulations
  validate :login
  field :encrypted_password

  def login
    begin
      Net::SSH.start(Yetting.host, username, :password => self.password, :timeout => 2)
    rescue
      errors.add(:username, "can't login to host")
    end
  end

  def password=(pass)
    self.update_attributes(:encrypted_password => pass.encrypt(:symmetric, :password => SECRET_KEY))
  end

  def password
    if self.encrypted_password == nil
      ''
    else
      self.encrypted_password.decrypt(:symmetric, :password => SECRET_KEY)
    end
  end

  def schedulable?
    self.max_concurrent_simulations > scheduled_count
  end

  def name
    self.username
  end

  def scheduled_count
    simulations.scheduled.count
  end
end
