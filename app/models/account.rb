# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  field :username
  field :host
  field :flux, :type => Boolean
  field :max_concurrent_simulations, :type => Integer
  validates_presence_of :username, :host, :max_concurrent_simulations
  validate :username_can_connect_to_host
  references_many :simulators
  key :name

  # checks whether a given account is capable of having more simulation jobs
  # assigned to it
  def schedulable?
    puts max_concurrent_simulations
    self.max_concurrent_simulations > scheduled_count
  end

  def name
    "#{self.username}@#{self.host}"
  end

  def username_can_connect_to_host
    begin
      Net::SSH.start(host, username, :timeout => 2)
    rescue
      errors.add(:username, "can't login to host")
    end
  end

  def scheduled_count
    sum = 0
    Game.all.each do |x|
      x.profiles.all.each do |y|
        sum += x.simulations.where(:profile_id => y.id).count
      end
    end
    sum
  end
end
