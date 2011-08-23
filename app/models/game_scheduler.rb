class GameScheduler < Scheduler
  include StrategyManipulation

  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  validates_presence_of :size

end