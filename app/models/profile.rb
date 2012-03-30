# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  
  embeds_many :role_instances
  embeds_many :sample_records
    
  has_many :simulations, :dependent => :destroy
  belongs_to :simulator
  
  field :size, :type => Integer
  field :parameter_hash, :type => Hash, :default => {}
  field :name
  field :sample_count, :type => Integer, :default => 0
  field :feature_avgs, :type => Hash, :default => {}
  field :feature_stds, :type => Hash, :default => {}
  field :feature_expected_values, :type => Hash, :default => {}

  index ([[:simulator_id,  Mongo::ASCENDING], [:parameter_hash, Mongo::ASCENDING], [:size, Mongo::ASCENDING], [:sample_count, Mongo::ASCENDING]])

  after_validation(:on => :create) do
    name.split("; ").each do |atom|
      role = self.role_instances.find_or_create_by(name: atom.split(": ")[0])
      role_size = atom.split(": ")[1].split(", ").reduce(:+){|sum, val| val.split(" ")[0].to_i}
      self["Role_#{role.name}_count"] = role_size
      atom.split(": ")[1].split(", ").each do |strat|
        role.strategy_instances.find_or_create_by(:name => strat.split(" ")[1], :count => strat.split(" ")[0].to_i)
      end
    end
  end
  
  after_create :find_games
  validates_presence_of :simulator, :name, :parameter_hash
  validates_uniqueness_of :name, scope: [:simulator_id, :parameter_hash]
  delegate :fullname, :to => :simulator, :prefix => true

  def role_hash
    ret_hash = {}
    name.split("; ").each do |atom|
      ret_hash[atom.split(": ")[0]] = []
      atom.split(": ")[1].split(", ").each do |s|
        s.split(" ")[0].to_i.times{ ret_hash[atom.split(": ")[0]] << s.split(" ")[1] }
      end
    end
    ret_hash
  end

  def strategy_count(role, strategy)
    role = role_instances.where(:name => role).first
    role == nil ? 0 : role.strategy_count(strategy)
  end

  def contains_strategy?(role, strategy)
    role = role_instances.where(:name => role).first
    return false if role == nil
    role.strategy_count(strategy) > 0
  end

  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue(ProfileScheduler, id)
  end

  def add_value(role, strategy, value)
    strategy = role_instances.find_or_create_by(name: role).strategy_instances.find_or_create_by(:name => strategy)
    if strategy.payoff == nil
      strategy.payoff = value
      strategy.payoff_std = [1, value, value**2, nil]
      strategy.save!
    else
      strategy.payoff = (strategy.payoff*(sample_records.count-1)+value)/sample_records.count
      s0 = strategy.payoff_std[0]+1
      s1 = strategy.payoff_std[1]+value
      s2 = strategy.payoff_std[2]+value**2
      strategy.payoff_std = [s0, s1, s2, Math.sqrt((s0*s2-s1**2)/(s0*(s0-1)))]
      strategy.save!
    end
    self.save!
  end
  
  def self.size_of_profile(name)
    sum = 0
    name.split("; ").each do |r|
      r.split(": ")[1].split(", ").each do |s|
        sum += s.split(" ")[0].to_i
      end
    end
    sum
  end
end