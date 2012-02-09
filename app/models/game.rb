class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator

  field :name
  field :size, type: Integer
  embeds_many :roles, :as => :role_owner
  embeds_many :features
  field :parameter_hash, type: Hash, default: {}

  belongs_to :simulator, :index => true
  index :parameter_hash
  validates_presence_of :simulator, :name, :size
  field :profile_ids, :type => Array, :default => []
  after_create :find_profiles

  def find_profiles
    Resque.enqueue(ProfileGatherer, id)
  end

  def self.new_game_from_scheduler(scheduler)
    game = Game.create!(name: scheduler.name, size: scheduler.size, simulator_id: scheduler.simulator_id, parameter_hash: scheduler.parameter_hash)
  end

  def add_roles_from_scheduler(scheduler)
    scheduler.roles.each {|r| roles.create!(name: r.name, count: r.count); r.strategies.each{|s| add_strategy(r.name, s.name)}}
  end
  
  def display_profiles
    query_hash = {:proto_string => strategy_regex, :_id.in => profile_ids, :sampled => true}
    roles.each {|r| query_hash["Role_#{r.name}_count"] = r.count}
    Profile.where(query_hash)
  end
  
  def as_json(options={})
    if options[:root] == true
      {:classPath => "minimal-egat.datatypes.NormalFormGame", :object => "#{self.to_json(:root => false)}"}
    else
      {:roles => roles.collect{|r| r.as_json(:root => false)}, :features => features.collect{|s| s.as_json(:root => false)}, :profiles => Profile.where(:proto_string => strategy_regex, :_id.in => profile_ids, :sampled => true).collect{|s| s.as_json(:root => false)}}
    end
  end

  private

  def strategy_regex
    Regexp.new("^"+roles.order_by(:name => :asc).collect{|r| "#{r.name}: (#{r.strategy_numbers.join('(, )?)*(')}(, )?)*"}.join("; ")+"$")
  end
end