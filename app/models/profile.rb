# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  embeds_many :role_instances
  has_many :simulations, dependent: :destroy
  embeds_many :sample_records
  belongs_to :simulator, index: true
  field :proto_string
  field :size, type: Integer
  field :parameter_hash, type: Hash, default: {}
  field :feature_avgs, type: Hash, default: {}
  field :feature_stds, type: Hash, default: {}
  field :feature_expected_values, type: Hash, default: {}
  field :sampled, type: Boolean, default: false
  index ([[:simulator_id,  Mongo::DESCENDING], [:parameter_hash, Mongo::DESCENDING], [:proto_string, Mongo::DESCENDING]]), unique: true
  index :sampled
  after_create :make_roles, :find_games
  validates_presence_of :simulator, :proto_string, :parameter_hash
  validates_uniqueness_of :proto_string, scope: [:simulator_id, :parameter_hash]

  def to_yaml
    ret_hash = {}
    proto_string.split("; ").each do |atom|
      ret_hash[atom.split(": ")[0]] = atom.split(": ")[1].delete("[]").split(", ")
    end
    ret_hash
  end

  def name
    proto_string
  end

  def sample_count
    sample_records.count
  end

  def make_roles
    proto_string.split("; ").each do |atom|
      role = self.role_instances.find_or_create_by(name: atom.split(": ")[0])
      atom.split(": ")[1].split(", ").each do |strat|
        role.strategy_instances.find_or_create_by(name: strat)
      end
    end
  end

  def strategy_count(role, strategy)
    proto_string.split("; ").each do |atom|
      return atom.split(": ")[1].split(", ").count(strategy) if atom.split(": ")[0] == role
    end
    return 0
  end

  def contains_strategy?(role, strategy)
    retval = false
    proto_string.split("; ").each do |atom|
      retval = true if atom.split(": ")[0] == role && atom.split(": ")[1].split(", ").include?(strategy)
    end
    return retval
  end

  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue(ProfileScheduler, id)
  end

  # def as_json(options={})
  #   {
  #     "classPath" => "datatypes.Profile",
  #     "object" => "{roles: [#{role_instances.collect{|r| r.as_json}.join(", ")}}"
  #   }
  # end

  def add_value(role, strategy, value)
    strategy = role_instances.find_or_create_by(name: role).strategy_instances.find_or_create_by(name: strategy)
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
    self.sampled = true
    self.save!
  end
end