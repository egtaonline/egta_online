# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document

  has_many :simulations, :dependent => :destroy
  has_many :features
  belongs_to :schedulable, :polymorphic => true
  belongs_to :simulator
  belongs_to :run_time_configuration
  embeds_many :profile_entries

  def name
    profile_entries.reduce(""){|str, pe| str + pe.name + ", "}[0..-3]
  end

  def scheduled_count
    simulations.reduce(0){|sum, sim| sum + sim.size}.to_f + profile_entries.first.samples.count
  end

end
