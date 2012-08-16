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
  
  index [[:simulator_id,  Mongo::ASCENDING], [:configuration, Mongo::ASCENDING], [:size, Mongo::ASCENDING]]
  validates_presence_of :simulator, :name, :size, :configuration, :simulator_fullname
  validates_numericality_of :size, only_integer: true, greater_than: 0
  
  def display_profiles
    query_hash = { :sample_count.gt => 0, :assignment => strategy_regex }
    roles.each {|r| query_hash["role_#{r.name}_count"] = r.count}
    profiles.where(query_hash)
  end
  
  private
  
  def strategy_regex
    Regexp.new("^"+roles.order_by(:name => :asc).collect{|r| "#{r.name}: \\d+ (#{r.strategies.join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")+"$")
  end
  
end