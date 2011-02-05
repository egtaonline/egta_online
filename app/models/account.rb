# This model class holds information about accounts that are
# required to run simulations on clusters (e.g. nyx)

class Account
  include Mongoid::Document

  field :username
  field :host

  validates_presence_of :username, :host

  referenced_in :simulations
  referenced_in :simulators

  # checks whether a given account is capable of having more simulation jobs
  # assigned to it
  def schedulable?
    max_concurrent_simulations > simulations.scheduled.count
  end

  def name
    "#{self.username}@#{self.host}"
  end
end
