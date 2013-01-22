class SymmetryGroup
  include Mongoid::Document

  embedded_in :role_strategy_partitionable, polymorphic: true
  embeds_many :players

  accepts_nested_attributes_for :players

  field :count, type: Integer
  field :role
  field :strategy
  field :payoff, type: Float
  field :payoff_sd, type: Float

  validates :count, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :role, presence: true
  validates :strategy, presence: true, uniqueness: { scope: :role }

  def payoffs
    players.collect { |p| p.payoff }
  end
  
  def update_statistics(payoffs)
    self.payoff = ArrayMath.average(payoffs)
    self.payoff_sd = ArrayMath.std_dev(payoffs)
    self.save!
  end
end