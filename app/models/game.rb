class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated

  field :name
  field :size, type: Integer
  field :role_strategy_hash, type: Hash, default: {}
  field :role_count_hash, type: Hash, default: {}
  field :parameter_hash, type: Hash, default: {}

  belongs_to :simulator, :index => true
  index :parameter_hash, background: true
  validates_presence_of :simulator, :name, :size
  field :profile_ids, :type => Array, :default => []
  after_create :find_profiles

  def add_strategy_by_name(role, strategy)
    puts role_strategy_hash
    role_strategy_hash[role] = [] if role_strategy_hash[role] == nil
    role_strategy_hash[role] << strategy
    hash = role_strategy_hash
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attribute(:role_strategy_hash, hash)
    puts Game.last.role_strategy_hash
  end
  
  def delete_strategy_by_name(role, strategy)
    role_strategy_hash[role].delete(strategy)
    hash = role_strategy_hash
    self.update_attribute(:role_strategy_hash, nil)
    self.update_attributes(role_strategy_hash: hash)
  end

  def strategy_regex(role)
    Regexp.new("^(#{role_strategy_hash[role].sort.join('(, )?)*(')}(, )?)*$")
  end

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end
end