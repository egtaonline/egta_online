class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator

  field :name
  field :size, type: Integer
  field :simulator_fullname
  embeds_many :roles, :as => :role_owner
  embeds_many :features
  field :parameter_hash, type: Hash, default: {}

  belongs_to :simulator, :index => true
  index :parameter_hash
  validates_presence_of :simulator, :name, :size
  has_and_belongs_to_many :profiles, :inverse_of => nil
  after_create :find_profiles
  before_save(:on => :create){self.simulator_fullname = self.simulator.fullname}

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end

  def self.new_game_from_scheduler(scheduler)
    game = Game.create!(name: scheduler.name, size: scheduler.size, simulator_id: scheduler.simulator_id, parameter_hash: scheduler.parameter_hash)
  end

  def add_roles_from_scheduler(scheduler)
    scheduler.roles.each {|r| roles.create!(name: r.name, count: r.count); r.strategies.each{|s| add_strategy(r.name, s.name)}}
    if scheduler.is_a? DeviationScheduler
      scheduler.deviating_roles.each{|r| r.strategies.each{|s| add_strategy(r.name, s.name)}}
    end
  end
  
  def display_profiles
    query_hash = {:name => strategy_regex, :sample_count.gt => 0}
    roles.each {|r| query_hash["Role_#{r.name}_count"] = r.count}
    profiles.where(query_hash)
  end

  private

  def strategy_regex
    Regexp.new("^"+roles.order_by(:name => :asc).collect{|r| "#{r.name}: \\d+ (#{r.strategies.join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")+"$")
  end
end