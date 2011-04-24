# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  has_many :simulations, :inverse_of => :account
  field :username
  field :flux, :type => Boolean
  field :max_concurrent_simulations, :type => Integer
  validates_presence_of :username, :max_concurrent_simulations
  field :encrypted_password

  def password=(pass)
    self.update_attributes(:encrypted_password => pass.encrypt(:symmetric, :password => SECRET_KEY))
  end

  def password
    self.encrypted_password.decrypt(:symmetric, :password => SECRET_KEY)
  end
  # checks whether a given account is capable of having more simulation jobs
  # assigned to it
  def schedulable?
    puts self.max_concurrent_simulations
    puts scheduled_count
    self.max_concurrent_simulations > scheduled_count
  end

  def name
    self.username
  end

  def scheduled_count
    simulations.scheduled.count
  end
end
