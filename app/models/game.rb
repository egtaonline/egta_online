class Game
  include Mongoid::Document
  include Mongoid::Timestamps::Updated
  include RoleManipulator::Base
  include RoleManipulator::RolePartition

  field :name, type: String
  field :size, type: Integer
  field :simulator_fullname, type: String

  before_validation(on: :create){ self.simulator_fullname = self.simulator_instance.simulator.fullname }

  embeds_many :roles, as: :role_owner
  belongs_to :simulator_instance

  index({ simulator_instance_id: 1, size: 1 })
  validates_presence_of :simulator_instance_id, :name, :size, :simulator_fullname
  validates_numericality_of :size, only_integer: true, greater_than: 0

  def self.create_with_simulator_instance(params)
    simulator_id = params.delete(:simulator_id)
    configuration = params.delete(:configuration)
    params[:simulator_instance_id] = SimulatorInstance.find_or_create_by(simulator_id: simulator_id, configuration: configuration).id
    Game.create!(params)
  end

  def profiles
    query_hash = { simulator_instance_id: simulator_instance_id, size: self.size, sample_count: { '$gt' => 0 }, assignment: strategy_regex }
    roles.each {|r| query_hash["role_#{r.name}_count"] = r.count }
    Profile.collection.find(query_hash)
  end

  def profile_counts
    selected = profiles.select(sample_count: 1).map{|p| p["sample_count"]}
    [selected.size, selected.reduce(:+)]
  end

  private

  def strategy_regex
    Regexp.new("^"+roles.order_by(name: :asc).collect{|r| "#{r.name}: \\d+ (#{r.strategies.join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")+"$")
  end

end