# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  embeds_many :role_instances
  has_many :simulations, :dependent => :destroy
  embeds_many :sample_records
  belongs_to :simulator
  field :proto_string
  field :size, :type => Integer
  field :parameter_hash, type: Hash, default: {}
  field :feature_avgs, type: Hash, default: {}
  field :feature_stds, type: Hash, default: {}
  field :feature_expected_values, type: Hash, default: {}
  field :sampled, type: Boolean, default: false
  index ([[:simulator_id,  Mongo::DESCENDING], [:parameter_hash, Mongo::DESCENDING], [:proto_string, Mongo::DESCENDING]]), unique: true
  index :sampled
  after_create :make_roles, :find_games
  validate :proto_string_has_correct_format
  validates_presence_of :simulator, :proto_string, :parameter_hash
  validates_uniqueness_of :proto_string, scope: [:simulator_id, :parameter_hash]

  def proto_string_has_correct_format
    if proto_string == "Non-existent strategy"
      errors.add(:proto_string, "requested non-existent strategy")
    elsif (proto_string =~ /^(\S+: (\d+, )*\d+; )*\S+: (\d+, )*\d+$/) == nil
      errors.add(:proto_string, "was malformed")
    end
  end

  def to_yaml
    ret_hash = {}
    proto_string.split("; ").each do |atom|
      ret_hash[atom.split(": ")[0]] = atom.split(": ")[1].split(", ").collect{|s| ::Strategy.where(:number => s).first.name }
    end
    ret_hash
  end

  def name
    proto_string.split("; ").collect do |role|
      role_name = role.split(": ").first
      strategies = role.split(": ").last.split(", ")
      role_name += ": "
      singular_strategies = ::Strategy.where(:number.in => strategies.uniq).collect {|s| "#{strategies.count(s.number.to_s)} #{s.name}"}
      role_name += singular_strategies.join(", ")
    end.join("; ")
  end

  def sample_count
    sample_records.count
  end

  def make_roles
    proto_string.split("; ").each do |atom|
      role = self.role_instances.find_or_create_by(name: atom.split(": ")[0])
      self["Role_#{role.name}_count"] = atom.split(": ")[1].split(", ").size
      atom.split(": ")[1].split(", ").each do |strat|
        role.strategy_instances.find_or_create_by(:name => ::Strategy.where(:number => strat).first.name)
      end
    end
    self.save
  end

  def strategy_count(role, strategy)
    name.split("; ").each do |r|
      if r.split(": ")[0] == role
        r.split(": ")[1].split(", ").each do |strat|
          return strat.split(" ")[0].to_i if strat.split(" ")[1] == strategy
        end
      end
    end
    return 0
  end

  def contains_strategy?(role, strategy)
    retval = false
    strategy = ::Strategy.where(:name => strategy).first.number
    if strategy != nil
      proto_string.split("; ").each do |atom|
        retval = (atom.split(": ")[0] == role && atom.split(": ")[1].split(", ").include?(strategy.to_s))
      end
    end
    return retval
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
    self.sampled = true
    self.save!
  end

  def self.convert_to_proto_string(name_string)
    if name_string =~ /^(\S+: (\S+, )*\S+; )*\S+: (\S+, )*\S+$/
      begin
        r = name_string.split("; ").sort.collect do |role|
          role.split(": ")[0]+": "+role.split(": ")[1].split(", ").sort.collect{|s| ::Strategy.where(:name => s).first.number}.join(", ")
        end
        r.join("; ")
      rescue
        "Non-existent strategy"
      end
    else
      ""
    end
  end
  
  #TODO add note that ',' and ';' are not valid for strategy names
  def self.size_of_profile(name_string)
    name_string.count(",")+name_string.count(";")+1
  end

  def as_json(options={})
    if options[:root] == true
      {:classPath => "minimal-egat.datatypes.Profile", :object => "#{self.to_json(:root => false)}"}
    else
      role_hash = {}
      role_instances.all.each do |r|
        s_hash = {}
        r.strategy_instances.each{|s| s_hash[s.name] = strategy_count(r.name, s.name)}
        role_hash[r.name] = s_hash
      end
      {:roleInstances => role_hash, :profileObservations => sample_records.collect{|s| s.as_json(:root => false)}}
    end
  end
end