# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  has_many :analysis_items, :as => :analyzable

  has_many :simulations, :dependent => :destroy
  has_many :features
  has_and_belongs_to_many :schedulers
  belongs_to :simulator

  has_and_belongs_to_many :games
  embeds_many :profile_entries
  field :sampled, :type => Boolean, :default => false
  field :proto_string
  field :parameter_hash, :type => Hash, :default => {}
  after_create :create_profile_entries
  after_create :find_games
  validates_presence_of :simulator
  validates_uniqueness_of :proto_string, :scope => [:simulator_id, :parameter_hash]
  scope :sampled, where(sampled: true)

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

  def find_games
    Game.where(simulator_id: self.simulator_id, parameter_hash: self.parameter_hash, size: self.size).each do |game|
      match = true
      self.strategy_array.uniq.each {|strat| match = (game.strategy_array.include?(strat) ? match : false)}
      if match == true
        game.profiles << self
        self.save!
      end
    end
  end
end
