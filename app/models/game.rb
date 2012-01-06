class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator

  field :name
  field :size, type: Integer
  embeds_many :roles, :as => :role_owner
  field :parameter_hash, type: Hash, default: {}

  belongs_to :simulator, :index => true
  index :parameter_hash, background: true
  validates_presence_of :simulator, :name, :size
  field :profile_ids, :type => Array, :default => []
  after_create :find_profiles

  def strategy_regex
    Regexp.new("^"+roles.collect{|r| "#{r.name}: (#{r.strategies.collect{|s| s.number}.sort.join('(, )?)*(')}(, )?)*"}.join("; ")+"$")
  end

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end

  def self.new_game_from_scheduler(scheduler)
    game = Game.new(name: scheduler.name, size: scheduler.size, simulator_id: scheduler.simulator_id, parameter_hash: scheduler.parameter_hash)
  end

  def add_roles_from_scheduler(scheduler)
    scheduler.roles.each {|r| roles.create!(name: r.name, count: r.count); r.strategies.each{|s| add_strategy(r.name, s.name)}}
  end
end