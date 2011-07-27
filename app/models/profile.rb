# Each Profile instance represents a single possible Strategy set for a Game.

class Profile < Analyzable

  has_many :simulations, :dependent => :destroy
  has_many :features
  has_and_belongs_to_many :schedulers
  belongs_to :simulator
  has_and_belongs_to_many :games
  embeds_many :profile_entries
  field :proto_string
  field :parameter_hash, :type => Hash, :default => {}
  after_create :create_profile_entries
#  validates_presence_of :simulator
#  validates_uniqueness_of :proto_string, :scope => [:simulator_id, :parameter_hash]

  def self.extract_strategies(profiles)
    profiles.reduce([]){|set, profile| set.concat profile.strategy_array.uniq }.uniq
  end

  def name
    profile_entries.reduce(""){|str, pe| str + pe.name + ", "}[0..-3]
  end

  def scheduled_count
    simulations.active.reduce(0){|sum, sim| sum + sim.size}.to_i + simulations.pending.reduce(0){|sum, sim| sum + sim.size}.to_i + profile_entries.first.samples.count
  end


  def contains_strategy?(strategy)
    profile_entries.where(:name => /^#{strategy}/).count > 0
  end

end
