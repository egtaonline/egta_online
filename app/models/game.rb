class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator::Base
  include RoleManipulator::RolePartition

  field :name
  field :size, type: Integer
  field :simulator_fullname
  field :configuration, type: Hash, default: {}
  
  embeds_many :roles, as: :role_owner
  belongs_to :simulator
  has_and_belongs_to_many :profiles, :inverse_of => nil
  
  index({ simulator_id: 1, configuration: 1, size: 1 })
  validates_presence_of :simulator, :name, :size, :configuration, :simulator_fullname
  validates_numericality_of :size, only_integer: true, greater_than: 0
  
  def display_profiles
    query_hash = { :_id => { '$in' => self.profile_ids}, :sample_count => { '$gt' => 0 }, :assignment => strategy_regex }
    roles.each {|r| query_hash["role_#{r.name}_count"] = r.count }
    query_hash
  end
  
  def as_json(options={})
    {
      id: self.id,
      name: self.name,
      simulator_fullname: self.simulator_fullname,
      configuration: self.configuration,
      roles: self.roles.collect{ |role| { name: role.name, strategies: role.strategies, count: role.count } },
      profiles: Profile.collection.find(display_profiles).select(:sample_count => 1, 'symmetry_groups.role' => 1, 'symmetry_groups.strategy' => 1, 'symmetry_groups.count' => 1, 'symmetry_groups.players.payoff' => 1)
    }
  end
  
  private
  
  def strategy_regex
    Regexp.new("^"+roles.order_by(:name => :asc).collect{|r| "#{r.name}: \\d+ (#{r.strategies.join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")+"$")
  end
  
end