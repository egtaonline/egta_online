# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  field :username
  field :flux, :type => Boolean
  field :max_concurrent_simulations, :type => Integer
  validates_presence_of :username, :max_concurrent_simulations
  validate :username_can_connect_to_host
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
    puts max_concurrent_simulations
    self.max_concurrent_simulations > scheduled_count
  end

  def name
    "#{self.username}@#{self.server_proxy.host}"
  end

  def username_can_connect_to_host
    begin
      if(self.password == nil)
        Net::SSH.start(ServerProxy::HOST, username, :timeout => 2)
      else
        Net::SSH.start(ServerProxy::HOST, username, :password => self.password, :timeout => 2)
      end
    rescue
      errors.add(:username, "can't login to host")
    end
  end

  def scheduled_count
    sum = 0
    Game.all.each do |x|
      x.profiles.all.each do |y|
        sum += y.simulations.where(:account_id => self.id).count
      end
    end
    sum
  end
end
