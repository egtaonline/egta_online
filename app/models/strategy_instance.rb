class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  field :name
  validates_uniqueness_of :name
  field :payoff, type: Float, default: nil
  field :payoff_std, type: Array, default: []

  def count
    role_instance.strategy_count(self.name)
  end
end