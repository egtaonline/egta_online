# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  
  embeds_many :symmetry_groups
  embeds_many :feature_observations

  has_many :simulations, :dependent => :destroy
  belongs_to :simulator
  
  field :size
  field :assignment, type: Hash
  field :sample_count, default: 0
  field :configuration, type: Hash, default: {}
  
  attr_accessible :assignment, :configuration

  # TODO: find the right indexes
  # index ([[:simulator_id,  Mongo::ASCENDING], [:configuration_id, Mongo::ASCENDING], [:size, Mongo::ASCENDING], [:sample_count, Mongo::ASCENDING]])

  validates_presence_of :simulator
  validates_uniqueness_of :assignment, scope: [:simulator_id, :configuration]
  delegate :fullname, :to => :simulator, :prefix => true

  after_create :find_games

  # def self.order_name(to_be_ordered)
  #   to_be_ordered.split("; ").collect{|r| r.split(": ")[0]+": "+r.split(": ")[1].split(", ").sort{|x, y| x.split(" ")[1] <=> y.split(" ")[1]}.join(", ")}.sort.join("; ")
  # end
  # 
  # def as_map
  #   # profile_map = {}
  #   # role_instances.each do |role|
  #   #   profile_map[role.name] = []
  #   #   role.strategy_instances.each do |strategy|
  #   #     strategy.count.times {|i| profile_map[role.name] << strategy.name}
  #   #   end
  #   # end
  #   # profile_map
  # end
  # 
  # def adjusted_sample_records
  #   self.sample_records.skip(10)
  # end
  # 
  # def payoff(role, strategy)
  #   return 0.0/0.0 if sample_count == 0
  #   pvals = payoff_values(role, strategy)
  #   pvals.reduce(:+)/(pvals.size.to_f)
  # end
  # 
  # def payoff_std(role, strategy)
  #   return 0.0/0.0 if (sample_count == 1 || sample_count == 0)
  #   average_payoff = payoff(role, strategy)
  #   Math.sqrt((1.0/(sample_count-1.0))*(payoff_values(role, strategy).reduce(0){|accum, val| accum+(val-average_payoff)**2.0}))
  # end
  # 
  # def strategy_count(role, strategy)
  #   role = role_instances.where(:name => role).first
  #   role == nil ? 0 : role.strategy_count(strategy)
  # end
  # 
  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue_in(5.minutes, ProfileScheduler, id)
  end
  # 
  # protected
  # 
  # def payoff_values(role, strategy)
  #   sample_records.collect{ |s| s.payoffs[role][strategy] }
  # end

end