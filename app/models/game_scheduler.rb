class GameScheduler < Scheduler
  include StrategyManipulation

  field :size, :type => Integer
  field :strategy_array, :type => Array, :default => []
  has_and_belongs_to_many :profiles
  validates_presence_of :size

end