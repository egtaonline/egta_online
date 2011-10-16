class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  field :name
  validates_uniqueness_of :name
  field :payoff, type: Float, default: nil
  field :payoff_std, type: Array, default: []
end