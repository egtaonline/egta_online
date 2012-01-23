class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name

  def strategy_count(strategy_name)
    profile.strategy_count(self.name, strategy_name)
  end

  def action_count_map
    ac_map = {}
    strategy_instances.all.each{|s| ac_map[::Strategy.where(:name => s.name).first.as_json(:only => [:name, :number])] = strategy_count(s.name)}
    ac_map
  end
  
  def as_json(options={})
    { "name" => self.name, "actionCountMap" => action_count_map }
  end

  # def as_json(options={})
  #   {
  #     "classPath" => "datatypes.Role",
  #     "object" => "{name: \"#{self.name}\", strategies: {#{strategy_instances.collect{|s| s.to_json + ": {count: #{strategy_count(s)}, payoff: #{s.payoff}}" }.join(", ")}}}"
  #   }
  # end
end