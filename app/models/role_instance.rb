class RoleInstance
  include Mongoid::Document
  embedded_in :profile
  field :name
  embeds_many :strategy_instances
  validates_uniqueness_of :name
  
  def strategy_count(strategy)
    profile.strategy_count(self.name, strategy)
  end
  
  # def as_json(options={})
  #   {
  #     "classPath" => "datatypes.Role",
  #     "object" => "{name: \"#{self.name}\", strategies: {#{strategy_instances.collect{|s| s.to_json + ": {count: #{strategy_count(s)}, payoff: #{s.payoff}}" }.join(", ")}}}"
  #   }
  # end
end