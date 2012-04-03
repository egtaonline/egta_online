class StrategyInstance
  include Mongoid::Document
  embedded_in :role_instance
  
  field :name
  field :count, :type => Integer
  field :payoff, :type => Float, :default => nil
  field :payoff_std, :type => Array, :default => []
  
  validates_uniqueness_of :name
  validates_presence_of :name, :count
end