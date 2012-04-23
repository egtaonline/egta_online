# Each Profile instance represents a single possible Strategy set for a Game.

class Profile
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  
  embeds_many :role_instances
  embeds_many :sample_records
    
  has_many :simulations, :dependent => :destroy
  belongs_to :simulator
  
  field :size, :type => Integer, :default => 0
  field :parameter_hash, :type => Hash, :default => {}
  field :name
  field :sample_count, :type => Integer, :default => 0

  index ([[:simulator_id,  Mongo::ASCENDING], [:parameter_hash, Mongo::ASCENDING], [:size, Mongo::ASCENDING], [:sample_count, Mongo::ASCENDING]])

  validates_format_of :name, :with => /\A(\w+: (\d+ \S+, )*\d+ \S+; )*\w+: (\d+ \S+, )*\d+ \S+\z/
  validates_presence_of :simulator, :name, :parameter_hash
  validates_uniqueness_of :name, scope: [:simulator_id, :parameter_hash]
  delegate :fullname, :to => :simulator, :prefix => true

  before_validation :order_name, :on => :create
  after_create :generate_roles, :find_games

  def order_name
    self.name = self.name.split("; ").collect{|r| r.split(": ")[0]+": "+r.split(": ")[1].split(", ").sort{|x, y| x.split(" ")[1] <=> y.split(" ")[1]}.join(", ")}.sort.join("; ")
  end

  def as_map
    profile_map = {}
    role_instances.each do |role|
      profile_map[role.name] = []
      role.strategy_instances.each do |strategy|
        strategy.count.times {|i| profile_map[role.name] << strategy.name}
      end
    end
    profile_map
  end

  def strategy_count(role, strategy)
    role = role_instances.where(:name => role).first
    role == nil ? 0 : role.strategy_count(strategy)
  end

  def find_games
    Resque.enqueue(GameAssociater, id)
  end

  def try_scheduling
    Resque.enqueue(ProfileScheduler, id)
  end
  
  protected
  
  def generate_roles
    self.size = 0
    name.split("; ").each do |atom|
      role = self.role_instances.find_or_create_by(name: atom.split(": ")[0])
      role_size = atom.split(": ")[1].split(", ").reduce(0){|sum, val| sum+val.split(" ")[0].to_i}
      self["Role_#{role.name}_count"] = role_size
      atom.split(": ")[1].split(", ").each do |strat|
        role.strategy_instances.find_or_create_by(:name => strat.split(" ")[1], :count => strat.split(" ")[0].to_i)
        self.size += strat.split(" ")[0].to_i
      end
    end
    self.save
  end
end