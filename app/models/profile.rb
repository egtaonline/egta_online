# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  
  embeds_many :symmetry_groups
  embeds_many :features_observations

  has_many :simulations, :dependent => :destroy
  belongs_to :simulator

  field :size
  field :assignment
  field :sample_count, type: Integer, default: 0
  field :configuration, type: Hash, default: {}
  
  attr_accessible :assignment, :configuration
  
  # TODO: find the right indexes
  index ({ simulator_id: 1, configuration: 1, size: 1 })
  index({ sample_count: 1 })

  validates_presence_of :simulator
  validates_format_of :assignment, with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/
  validates_uniqueness_of :assignment, scope: [:simulator_id, :configuration]
  delegate :fullname, :to => :simulator, :prefix => true

  after_create :find_games
  
  def strategies_for(role_name)
    symmetry_groups.where(role: role_name).collect{ |s| s.strategy }.uniq
  end
  
  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue_in(5.minutes, ProfileScheduler, id)
  end

  def create_player(role, strategy, payoff, pfeatures)
    symmetry_groups.where(role: role, strategy: strategy).first.players.create(payoff: payoff.to_f, features: pfeatures)
  end
  
  def scheduled?
    simulations.active.count > 0
  end
  
  def features
    fhash = Hash.new{ |hash,key| hash[key] = [] }
    features_observations.each do |f|
      f.features.each do |key, value|
        fhash[key] << value
      end
    end
    fhash.each do |key, value|
      fhash[key] = value.compact
      fhash[key] = fhash[key].to_scale.mean if fhash[key].size > 0
    end
    fhash
  end
end