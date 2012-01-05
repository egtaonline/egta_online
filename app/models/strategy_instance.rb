class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  field :strategy_id
  validates_uniqueness_of :strategy_id
  field :payoff, :type => Float, :default => nil
  field :payoff_std, :type => Array, :default => []

  def count
    role_instance.strategy_count(strategy_id)
  end
end